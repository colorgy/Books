class Order < ActiveRecord::Base
  include AASM
  acts_as_paranoid
  has_paper_trail

  belongs_to :user
  belongs_to :course
  belongs_to :book
  belongs_to :bill

  validates :user, presence: true
  validates :course, presence: true
  validates :book, presence: true

  after_initialize :set_batch, :set_organization_code, :set_group, :set_price

  aasm column: :state do
    state :new, initial: true
    state :payment_pending
    state :paid
    state :delivered
    state :cancelled

    event :bill_created do
      transitions :from => :new, :to => :payment_pending
      transitions :from => :payment_pending, :to => :payment_pending
    end

    event :pay do
      transitions :from => :payment_pending, :to => :paid
    end

    event :deliver do
      transitions :from => :paid, :to => :delivered
    end

    event :cancel do
      transitions :from => :new, :to => :cancelled
      transitions :from => :payment_pending, :to => :cancelled
    end
  end

  def set_batch
    return unless self.batch.blank?
    self.batch = "#{Course.current_year}-#{Course.current_term}-#{Settings.order_batch}"
  end

  def set_organization_code
    return unless self.organization_code.blank?
    self.organization_code = course.organization_code
  end

  def set_group
    return unless self.group.blank?
    self.group = "#{Course.current_year}-#{Course.current_term}-#{Settings.order_batch}-#{course.id}-#{book.id}"
  end

  def set_price
    return unless self.price.blank?
    self.price = self.book.price
  end

  def save_with_bill!(bill)
    self.bill_id = bill.id
    self.bill_created
    save!
  end
end
