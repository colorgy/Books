class Bill < ActiveRecord::Base
  include AASM
  acts_as_paranoid
  has_paper_trail

  self.inheritance_column = :_type_disabled

  cattr_accessor :test

  store :data, accessors: [:invoice_code, :invoice_love_code, :invoice_uni_num]

  belongs_to :user
  has_many :orders

  validates :type, presence: true, inclusion: { in: %w(payment_code credit_card virtual_account) }
  validates :invoice_type, presence: true, inclusion: { in: %w(digital paper code love_code uni_num) }
  validates :uuid, presence: true
  validates :user, presence: true
  validates :type, presence: true
  validates :price, presence: true
  validates :amount, presence: true
  validates :state, presence: true
  validates :invoice_type, presence: true

  after_initialize :set_uuid, :calculate_amount
  before_save :get_payment_info, only: :create

  aasm column: :state do
    state :payment_pending, initial: true
    state :paid

    event :pay do
      transitions :from => :payment_pending, :to => :paid do
        after do
          orders.each do |order|
            order.pay!
          end
        end
      end
    end
  end

  def set_uuid
    return unless self.uuid.blank?
    self.uuid = "bo#{SecureRandom.uuid[2..28]}"
  end

  def calculate_amount
    if type == 'payment_code'
      self.amount = price + 35
    else
      self.amount = price
    end
  end

  def get_payment_info
    return if @@test
    case type
    when 'payment_code'
      self.payment_code = NewebPayService.get_payment_code(uuid, amount, payname: user.name)
    else
      raise 'unknown payment method'
    end
  end
end
