class Order < ActiveRecord::Base
  include AASM
  acts_as_paranoid
  has_paper_trail

  scope :paid, ->  { where(state: :paid) }
  scope :has_paid, ->  { where(state: [:paid, :delivering, :leader_received, :delivered, :received]) }
  scope :unpaid, ->  { where(state: [:new, :payment_pending, :expired, :cancelled]) }

  belongs_to :user
  belongs_to :course, primary_key: :ucode, foreign_key: :course_ucode
  belongs_to :book, -> { with_deleted }
  belongs_to :bill, -> { with_deleted }, primary_key: :uuid, foreign_key: :bill_uuid
  belongs_to :group, primary_key: :code, foreign_key: :group_code
  belongs_to :package

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :price,
           to: :book, prefix: true, allow_nil: true
  delegate :organization_code, :department_code, :lecturer_name,
           :year, :term, :name, :code, :url, :required, :book_isbn,
           to: :course, prefix: true, allow_nil: true
  delegate :sid, :uid, :name, :fbid, :username, :avatar_url, :cover_photo_url,
           to: :user, prefix: true, allow_nil: true
  delegate :leader, :leader_name, :leader_avatar_url,
           to: :group, prefix: true, allow_nil: true

  validates :user, presence: true
  validates :book, presence: true

  after_initialize :init_price
  before_save :init_price
  after_create :count_group_orders

  aasm column: :state do
    state :new, initial: true
    state :payment_pending  # has a non-expired bill
    state :expired  # invalid order, dead state
    state :paid  # paid, but can be refund automatically
    state :ready  # order processing, cannot be refund automatically
    state :delivering  # order has marked as shiped by the supplier
    state :leader_received  # group leader has stated that (s)he has recived it
    state :delivered  # group leader or supplier has stated that its delivered
    state :received  # orderer states that (s)he has received it
    state :cancelled  # the order has been cancelled and refunded (if paid)

    event :bill_created do
      transitions :from => :new, :to => :payment_pending
      transitions :from => :payment_pending, :to => :payment_pending
    end

    event :pay, after: :count_group_orders do
      transitions :from => :new, :to => :paid
      transitions :from => :payment_pending, :to => :paid
    end

    event :ready do
      transitions :from => :paid, :to => :ready
      transitions :from => :expired, :to => :expired
    end

    event :expire do
      transitions :from => :payment_pending, :to => :expired
      transitions :from => :new, :to => :expired
      transitions :from => :expired, :to => :expired
    end

    event :ship do
      transitions :from => :paid, :to => :delivering
    end

    event :leader_receive do
      transitions :from => :delivering, :to => :leader_received
    end

    event :leader_deliver do
      transitions :from => :leader_received, :to => :delivered
      transitions :from => :delivering, :to => :delivered
    end

    event :receive do
      transitions :from => :delivered, :to => :received
      transitions :from => :leader_received, :to => :received
      transitions :from => :delivering, :to => :received
    end

    event :cancel, after: :count_group_orders do
      transitions :from => :new, :to => :cancelled
      transitions :from => :expired, :to => :cancelled
      transitions :from => :paid, :to => :cancelled do
        after do
          user.credits += price
          user.save!
        end
      end
    end

    event :revert do
      transitions :from => :delivering, :to => :paid, :if => :recently_updated
      transitions :from => :leader_received, :to => :delivering, :if => :recently_updated
      transitions :from => :delivered, :to => :leader_received, :if => :recently_updated
      transitions :from => :received, :to => :leader_received, :if => :recently_updated
    end

    event :force_revert do
      transitions :from => :delivering, :to => :paid
      transitions :from => :leader_received, :to => :delivering
      transitions :from => :delivered, :to => :leader_received
      transitions :from => :received, :to => :leader_received
    end
  end

  def init_price
    return unless self.price.blank?
    self.price = self.book.try(:price)
  end

  def count_group_orders
    group.count_orders! if group.present?
  end

  # def save_with_bill!(bill)
  #   self.bill_id = bill.id
  #   self.bill_created
  #   save!
  # end

  def recently_updated
    updated_at > 3.minute.ago
  end

  def has_paid?
    %w(paid delivering leader_received delivered received).include?(state)
  end

  def paid?
    state == 'paid'
  end
end
