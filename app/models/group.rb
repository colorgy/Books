class Group < ActiveRecord::Base
  scope :current, ->  { where(batch: Order.current_batch) }

  belongs_to :leader, class_name: User, primary_key: :id, foreign_key: :leader_id
  has_many :orders, primary_key: :code, foreign_key: :group_code
  belongs_to :course
  belongs_to :book

  delegate :name, :avatar_url, :fbid, :gender,
           to: :leader, prefix: true, allow_nil: true
  delegate :name, :lecturer_name,
           to: :course, prefix: true, allow_nil: true
  delegate :name,
           to: :book, prefix: true, allow_nil: true

  validates :code, presence: true
  validates :course, presence: true
  validates :book, presence: true

  after_initialize :set_batch

  def self.generate_code(organization_code, course_id, book_id)
    "#{Order.current_batch}-#{organization_code}-#{course_id}-#{book_id}"
  end

  def set_batch
    return unless self.batch.blank?
    self.batch = Order.current_batch
  end

  def set_batch!
    self.batch = Order.current_batch
    save!
  end
end
