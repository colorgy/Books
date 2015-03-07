class Group < ActiveRecord::Base
  has_paper_trail

  scope :current, ->  { where(batch: BatchCodeService.current_batch) }
  scope :unshipped, ->  { where(shipped_at: nil) }
  scope :shipped, ->  { where.not(shipped_at: nil) }
  scope :undelivered, ->  { where(received_at: nil) }
  scope :delivered, ->  { where.not(received_at: nil) }

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

  validates :code, presence: true
  validates :course, presence: true
  validates :book, presence: true

  after_initialize :set_batch, :set_organization_code, :set_code
  before_validation :set_organization_code, :set_code
  before_save :set_organization_code, :set_code

  def set_batch
    return unless self.batch.blank?
    self.batch = BatchCodeService.current_batch
  end

  def set_batch!
    self.batch = BatchCodeService.current_batch
    save!
  end

  def set_organization_code
    return unless self.organization_code.blank?
    self.organization_code = course.try(:organization_code)
  end

  def set_organization_code!
    self.organization_code = course.try(:organization_code)
    save!
  end

  def set_code
    return unless self.code.blank?
    return if course_id.blank? || book_id.blank?
    self.code = BatchCodeService.generate_group_code(organization_code, course_id, book_id)
  end

  def ship!
    return unless shipped_at.blank?
    ActiveRecord::Base.transaction do
      update_attributes(shipped_at: Time.now)
      orders.each do |order|
        order.ship! if order.may_ship?
      end
    end
  end

  def receive!
    return unless shipped_at.present?
    ActiveRecord::Base.transaction do
      update_attributes(received_at: Time.now)
      orders.each do |order|
        order.leader_receive! if order.may_leader_receive?
      end
    end
  end
end
