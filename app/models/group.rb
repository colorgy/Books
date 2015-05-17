class Group < ActiveRecord::Base
  include AASM
  has_paper_trail

  scope :publ, ->  { where(public: true) }
  scope :priv, ->  { where(public: false) }
  scope :ended, ->  { where('deadline < ?', Time.now) }
  scope :unshipped, ->  { where(shipped_at: nil) }
  scope :shipped, ->  { where.not(shipped_at: nil) }
  scope :unreceived, ->  { where(received_at: nil) }
  scope :received, ->  { where.not(received_at: nil) }

  belongs_to :leader, class_name: User, primary_key: :id, foreign_key: :leader_id
  has_many :orders, primary_key: :code, foreign_key: :group_code
  belongs_to :course, -> { with_deleted }
  belongs_to :book, -> { with_deleted }

  delegate :name, :avatar_url, :fbid, :gender,
           to: :leader, prefix: true, allow_nil: true
  delegate :name, :lecturer_name,
           to: :course, prefix: true, allow_nil: true
  delegate :name,
           to: :book, prefix: true, allow_nil: true

  validates :code, :book, :leader, :pickup_datetime, presence: true
  validate :book_org_code_matches_org_code

  after_initialize :end_if_deadline_passed
  before_create :set_deadline
  before_validation :set_organization_code, :set_code

  aasm column: :state do
    state :grouping, initial: true
    state :ended
    state :delivering
    state :delivered
    state :received

    event :end do
      transitions from: :grouping, to: :ended
    end

    event :ship do
      transitions from: :ended, to: :delivering
      after do
        update_attributes(shipped_at: Time.now)
        orders.each do |order|
          order.ship! if order.may_ship?
        end
      end
    end

    event :delivered do
      transitions from: :delivering, to: :delivered
      after do
        # update_attributes(delivered_at: Time.now)
      end
    end

    event :receive do
      transitions from: :delivering, to: :received
      transitions from: :received, to: :received
      after do
        update_attributes(received_at: Time.now)
        orders.each do |order|
          order.leader_receive! if order.may_leader_receive?
        end
      end
    end
  end

  class << self
    def code_for(batch: nil, year: nil, term: nil, book_id: nil, course_id: nil, org_code: nil, rand: nil)
      year ||= DatetimeService.current_year
      term ||= DatetimeService.current_term
      batch = DatetimeService.batch(year: year, term: term) if batch.blank?
      rand ||= SecureRandom.hex(4)[1..7]
      "#{batch}-#{org_code}-#{book_id}-#{course_id}-#{rand}"
    end

    alias_method :code, :code_for
  end

  alias_attribute :org_code, :organization_code

  def set_organization_code
    return unless self.organization_code.blank?
    self.organization_code = course.try(:organization_code)
  end

  alias_method :set_org_code, :set_organization_code

  def set_code
    return unless self.code.blank?
    self.code = Group.code_for(book_id: book_id, course_id: course_id, org_code: org_code)
  end

  def set_deadline
    self.deadline = (pickup_datetime - book.delivery_processing_time).change(hour: 0)
  end

  def end_if_deadline_passed
    self.end if may_end? && deadline.present? && Time.now > deadline
  end

  # Deprecated
  def ship!
    return unless shipped_at.blank?
    ActiveRecord::Base.transaction do
      update_attributes(shipped_at: Time.now)
      orders.each do |order|
        order.ship! if order.may_ship?
      end
    end
  end

  # Deprecated
  def receive!
    return unless shipped_at.present?
    ActiveRecord::Base.transaction do
      update_attributes(received_at: Time.now)
      orders.each do |order|
        order.leader_receive! if order.may_leader_receive?
      end
    end
  end

  private

  def book_org_code_matches_org_code
    errors.add(:book, "The book in that organization is not permitted") if book.present? && book.organization_code.present? && book.organization_code != organization_code
  end
end
