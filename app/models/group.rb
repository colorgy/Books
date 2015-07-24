class Group < ActiveRecord::Base
  include AASM
  has_paper_trail

  # What hour in a day will the grouping end?
  END_AT_DAY_HOUR = 3
  # The bill's deadline
  BILL_DEADLINE_DELAY = 30.minutes
  # Wait for this time for a ended group to become ready (for shipping, i.e.
  # all order and bill status will not change)
  # CAUTION: this must be bigger then
  # Bill::PAYMENT_DEADLINE_ADJ + BILL_DEADLINE_DELAY
  # since bills can be continually paid before the group is ready
  WAIT_BEFORE_READY_AFTER_ENDED = 3.hours

  self.primary_key = :code

  scope :in_org, ->(org_code) { (org_code.blank? || org_code == 'public') ? where(organization_code: [nil, '', 'public']) : where(organization_code: org_code) }
  scope :publ, ->  { where(public: true) }
  scope :priv, ->  { where(public: false) }
  scope :ended, ->  { where('deadline < ?', Time.now) }
  scope :grouping, ->  { where('deadline > ?', Time.now) }
  scope :unshipped, ->  { where(shipped_at: nil) }
  scope :shipped, ->  { where.not(shipped_at: nil) }
  scope :unreceived, ->  { where(received_at: nil) }
  scope :received, ->  { where.not(received_at: nil) }

  belongs_to :leader, class_name: User, primary_key: :id, foreign_key: :leader_id
  has_many :orders, primary_key: :code, foreign_key: :group_code
  belongs_to :course, primary_key: :ucode, foreign_key: :course_ucode
  belongs_to :book, -> { with_deleted }

  delegate :name, :avatar_url, :fbid, :gender,
           to: :leader, prefix: true, allow_nil: true
  delegate :name, :lecturer_name,
           to: :course, prefix: true, allow_nil: true
  delegate :name, :isbn, :internal_code, :price, :image_url,
           to: :book, prefix: true, allow_nil: true

  validates :code, :book, :leader, :pickup_datetime, presence: true
  validate :book_org_code_matches_org_code

  after_initialize :end_if_deadline_passed, :automatically_be_ready
  before_create :set_deadline
  before_validation :set_organization_code_if_blank, :set_code_if_blank, :set_supplier_code

  aasm column: :state do
    state :grouping, initial: true
    state :ended  # the group has passed it's deadline, no new orders can add
    state :faild  # the grouping has faild and all orders has been canceled
    state :ready  # the group order are expected to be proceeded by supplier
    state :delivering  # the supplier states that (s)he shipped the order
    state :delivered
    state :received  # the group leader states that (s)he has received it

    event :end do
      transitions from: :grouping, to: :ended
    end

    event :ready do
      transitions from: :grouping, to: :ready do
        # a group can not be ready if it contains orders that might change
        # their state (e.g. payment_pending)
        guard do
          order_states = orders.map(&:state)
          !(order_states.include?('new') || order_states.include?('payment_pending'))
        end
      end
      after do
        # the orders may be processing, so mark them (to prevent being refund)
        orders.each(&:ready!)
      end
    end

    event :ship do
      transitions from: :ready, to: :delivering
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
    def code_for(batch: nil, year: nil, term: nil, book_id: nil, course_ucode: nil, org_code: nil, rand: nil)
      year ||= DatetimeService.current_year
      term ||= DatetimeService.current_term
      batch = DatetimeService.batch(year: year, term: term) if batch.blank?
      rand ||= SecureRandom.hex(4)[1..7]
      "#{batch}-#{org_code}-#{book_id}-#{course_ucode}-#{rand}"
    end

    alias_method :code, :code_for
  end

  alias_attribute :org_code, :organization_code

  def set_organization_code_if_blank
    return unless self.organization_code.blank?
    self.organization_code = course.try(:organization_code)
  end

  def set_code_if_blank
    return unless self.code.blank?
    self.code = Group.code_for(book_id: book_id, course_ucode: course_ucode, org_code: org_code)
  end

  def set_deadline
    self.deadline = (pickup_datetime - book.delivery_processing_time).change(hour: END_AT_DAY_HOUR)
  end

  def set_supplier_code
    return if book.blank?
    self.supplier_code = book.supplier_code
  end

  def end_if_deadline_passed
    self.end! if may_end? && deadline.present? && Time.now > deadline
  end

  def automatically_be_ready
    self.ready! if may_ready? && deadline.present? && Time.now > deadline + WAIT_BEFORE_READY_AFTER_ENDED
  end

  def count_orders
    self.orders_count = orders.has_paid.count
    self.unpaid_orders_count = orders.unpaid.count
  end

  def count_orders!
    count_orders
    save!
  end

  def bill_deadline
    deadline + BILL_DEADLINE_DELAY
  end

  # Deprecated
  # def ship!
  #   return unless shipped_at.blank?
  #   ActiveRecord::Base.transaction do
  #     update_attributes(shipped_at: Time.now)
  #     orders.each do |order|
  #       order.ship! if order.may_ship?
  #     end
  #   end
  # end

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
