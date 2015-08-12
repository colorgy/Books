class Bill < ActiveRecord::Base
  include AASM
  acts_as_paranoid
  has_paper_trail

  # All allowed payment types
  TYPES = %w(payment_code credit_card virtual_account test_clickpay test_autopay)
  # All allowed invoice types
  INVOICE_TYPES = %w(digital paper code cert love_code uni_num)
  # Deadline adjustment of the bill, we will not mark the bill as expired
  # (marking as expired also means stop tracking its status) after the bill
  # deadline haven't been overdue for more than this time.
  PAYMENT_DEADLINE_ADJ = 2.hours
  TYPE_FEE_EQUATIONS = {
    payment_code: 'n + 35',
    credit_card: 'n * 1.018 + 0.5'
  }

  self.inheritance_column = :_type_disabled

  cattr_accessor :test

  scope :paid, -> { where(state: 'paid') }
  scope :payment_pending, -> { where(state: 'payment_pending') }
  scope :unpaid, -> { where.not(state: 'paid') }

  store :data, accessors: [:invoice_code, :invoice_love_code, :invoice_uni_num, :invoice_cert]

  belongs_to :user
  has_many :orders, primary_key: :uuid, foreign_key: :bill_uuid
  has_many :packages, through: :orders

  delegate :sid, :uid, :name, :fbid, :username, :avatar_url, :cover_photo_url,
           to: :user, prefix: true, allow_nil: true

  validates :type, presence: true,
                   inclusion: { in: TYPES }
  validates :invoice_type, presence: true,
                           inclusion: { in: INVOICE_TYPES }
  validates :uuid, presence: true
  validates :user, presence: true
  validates :type, presence: true
  validates :price, presence: true
  validates :amount, presence: true
  validates :state, presence: true
  validates :deadline, presence: true

  after_initialize :init_uuid, :expire_if_deadline_passed
  before_create :calculate_amount, :get_payment_info

  aasm column: :state do
    state :payment_pending, initial: true
    state :paid
    state :expired

    event :pay do
      transitions :from => :payment_pending, :to => :paid do
        after do
          self.paid_at = Time.now
          orders.each(&:pay!)
        end
      end
    end

    event :expire do
      transitions :from => :payment_pending, :to => :expired do
        after do
          orders.each(&:expire!)
        end
      end
    end
  end

  class << self
    def allowed_types
      return @allowed_types if @allowed_types.present?
      @allowed_types = (ENV['ALLOWED_BILL_TYPES'].split(',') & TYPES)
    end

    def type_selections
      @bill_type_selections ||= allowed_types.map { |bt| [I18n.t(bt, scope: :bill_types), bt] }
    end

    def type_label(bt)
      I18n.t(bt, scope: :bill_types)
    end

    def invoice_type_label(bit)
      I18n.t(bit, scope: :invoice_types)
    end
  end

  # Initialize the uuid on creation
  def init_uuid
    return unless self.uuid.blank?
    self.uuid = "bo#{SecureRandom.uuid[2..28]}"
  end

  # Calaulate and update the total amount (addes the payment fees,
  # minus credits used) to pay, with price
  # and used_credits already set
  def calculate_amount
    processing_fee = 0
    amount = price - used_credits

    if TYPE_FEE_EQUATIONS[type.to_sym].present?
      n = amount
      self.processing_fee = eval(TYPE_FEE_EQUATIONS[type.to_sym]) - amount
    end

    amount += self.processing_fee
    self.amount = amount
  end

  # Get the payment information from 3rd services to make this bill payable
  # TODO: Implement
  def get_payment_info
    raise 'bill type not allowed' unless Bill.allowed_types.include?(type)
    return if Rails.env.test?

    self.deadline = 28.days.from_now if deadline > 28.days.from_now

    case type
    when 'payment_code'
      self.payment_code = NewebPayService.get_payment_code(uuid, amount, payname: user.name, duedate: deadline)

    when 'virtual_account'
      self.virtual_account = SinoPacService.get_virtual_account(uuid, amount, payname: user.name, duedate: deadline)
    end
  end

  def pay_if_paid!
    case type
    when 'payment_code'
      pay! if NewebPayService.reget_payment_code(uuid, amount)

    when 'virtual_account'
      pay! if SinoPacService.virtual_account_paid?(uuid)

    when 'credit_card'
      pay! if SinoPacService.credit_card_paid?(uuid)
    end
  end

  def expire_if_deadline_passed
    self.expire! if may_expire? && deadline.present? && Time.now > deadline + PAYMENT_DEADLINE_ADJ
  end

  def credit_card_pay_link(text = '按此進行信用卡付款')
    SinoPacService.credit_card_pay_link(uuid, amount, text: text)
  end
end
