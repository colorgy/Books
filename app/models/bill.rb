class Bill < ActiveRecord::Base
  include AASM
  acts_as_paranoid
  has_paper_trail

  self.inheritance_column = :_type_disabled

  cattr_accessor :test

  scope :paid, -> { where(state: 'paid') }
  scope :unpaid, -> { where.not(state: 'paid') }

  store :data, accessors: [:invoice_code, :invoice_love_code, :invoice_uni_num, :invoice_cert]

  belongs_to :user
  has_many :orders

  delegate :sid, :uid, :name, :fbid, :username, :avatar_url, :cover_photo_url,
           to: :user, prefix: true, allow_nil: true

  validates :type, presence: true, inclusion: { in: %w(payment_code credit_card virtual_account) }
  validates :invoice_type, presence: true, inclusion: { in: %w(digital paper code cert love_code uni_num) }
  validates :uuid, presence: true
  validates :user, presence: true
  validates :type, presence: true
  validates :price, presence: true
  validates :amount, presence: true
  validates :state, presence: true
  validates :invoice_type, presence: true

  after_initialize :init_uuid
  before_create :calculate_amount, :get_payment_info

  aasm column: :state do
    state :payment_pending, initial: true
    state :paid

    event :pay do
      transitions :from => :payment_pending, :to => :paid do
        after do
          self.paid_at = Time.now
          orders.each do |order|
            order.pay!
          end
        end
      end
    end
  end

  # Return the allowed bill types i.e. payment methods
  def self.allowed_types
    @@allowed_types ||= ENV['ALLOWED_BILL_TYPES'].split(',')
  end

  # Initialize the uuid on creation
  def init_uuid
    return unless self.uuid.blank?
    self.uuid = "bo#{SecureRandom.uuid[2..28]}"
  end

  # Calaulate and update the total amount (addes the payment fees,
  # minus credits used) to pay
  def calculate_amount
    self.amount = price
    self.amount -= used_credits if used_credits.present?
    if type == 'payment_code'
      self.amount = price + 35
    else
      self.amount = price
    end
  end

  # Get the payment information from 3rd services to make this bill payable
  def get_payment_info
    raise 'bill type not allowed' unless Bill.allowed_types.include?(type)
    return if Rails.env.test?
    case type
    when 'payment_code'
      if Settings.orders_close_date.is_a? Time
        self.payment_code = NewebPayService.get_payment_code(uuid, amount, payname: user.name, duedate: Settings.orders_close_date)
      else
        self.payment_code = NewebPayService.get_payment_code(uuid, amount, payname: user.name)
      end
    else
      raise 'unknown payment method'
    end
  end
end
