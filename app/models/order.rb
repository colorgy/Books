class Order < ActiveRecord::Base
  include AASM
  acts_as_paranoid
  has_paper_trail

  scope :current, ->  { where(batch: BatchCodeService.current_batch) }
  scope :paid, ->  { where(state: :paid) }
  scope :has_paid, ->  { where(state: [:paid, :shipped, :leader_received, :delivered, :received]) }

  belongs_to :user
  belongs_to :course, -> { with_deleted }
  belongs_to :book, -> { with_deleted }
  belongs_to :bill, -> { with_deleted }
  belongs_to :group, primary_key: :code, foreign_key: :group_code

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
  validates :course, presence: true
  validates :book, presence: true

  after_initialize :set_batch, :set_price, :set_organization_code, :set_group_code
  before_save :set_price, :set_organization_code, :set_group_code

  aasm column: :state do
    state :new, initial: true
    state :payment_pending
    state :paid
    state :shipped
    state :leader_received
    state :delivered
    state :received
    state :cancelled

    event :bill_created do
      transitions :from => :new, :to => :payment_pending
      transitions :from => :payment_pending, :to => :payment_pending
    end

    event :pay do
      transitions :from => :payment_pending, :to => :paid
    end

    event :ship do
      transitions :from => :paid, :to => :shipped
    end

    event :leader_receive do
      transitions :from => :shipped, :to => :leader_received
    end

    event :leader_deliver do
      transitions :from => :leader_received, :to => :delivered
      transitions :from => :shipped, :to => :delivered
    end

    event :receive do
      transitions :from => :delivered, :to => :received
      transitions :from => :leader_received, :to => :received
      transitions :from => :shipped, :to => :received
    end

    event :cancel do
      transitions :from => :new, :to => :cancelled
      transitions :from => :payment_pending, :to => :cancelled
    end

    event :revert do
      transitions :from => :shipped, :to => :paid, :if => :recently_updated
      transitions :from => :leader_received, :to => :shipped, :if => :recently_updated
      transitions :from => :delivered, :to => :leader_received, :if => :recently_updated
      transitions :from => :received, :to => :leader_received, :if => :recently_updated
    end

    event :force_revert do
      transitions :from => :shipped, :to => :paid
      transitions :from => :leader_received, :to => :shipped
      transitions :from => :delivered, :to => :leader_received
      transitions :from => :received, :to => :leader_received
    end
  end

  def set_batch
    return unless self.batch.blank?
    self.batch = BatchCodeService.current_batch
  end

  def set_organization_code
    self.organization_code = course.try(:organization_code)
  end

  def set_group_code
    if self.group_code.blank?
      self.group_code = BatchCodeService.generate_group_code(organization_code, course.id, book.id) if course.present? && book.present?
    else
      self.group_code = BatchCodeService.generate_group_code(organization_code, course.id, book.id, batch: batch) if course.present? && book.present?
    end
  end

  def set_price
    return unless self.price.blank?
    self.price = self.book.try(:price)
  end

  def save_with_bill!(bill)
    self.bill_id = bill.id
    self.bill_created
    save!
  end

  def recently_updated
    updated_at > 3.minute.ago
  end
end
