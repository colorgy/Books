class Order < ActiveRecord::Base
  include AASM
  acts_as_paranoid
  has_paper_trail

  belongs_to :user
  belongs_to :course
  belongs_to :book
  belongs_to :bill
  belongs_to :group, primary_key: :code, foreign_key: :group_code

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :price,
           to: :book, prefix: true, allow_nil: true
  delegate :organization_code, :department_code, :lecturer_name,
           :year, :term, :name, :code, :url, :required, :book_isbn,
           to: :course, prefix: true, allow_nil: true
  delegate :leader, :leader_name, :leader_avatar,
           to: :group, prefix: true, allow_nil: true

  validates :user, presence: true
  validates :course, presence: true
  validates :book, presence: true

  after_initialize :set_batch, :set_price, :set_organization_code, :set_group_code
  before_save :set_organization_code, :set_group_code

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
    self.organization_code = course.organization_code
  end

  def set_group_code
    self.group_code = "#{batch}-#{organization_code}-#{course.id}-#{book.id}"
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
