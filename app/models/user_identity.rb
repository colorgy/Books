class UserIdentity < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sid, use: :finders

  scope :lecturer, -> { where(identity: ['lecturer', 'professor']) }

  belongs_to :user
  has_many :courses, ->(o) { where "courses.organization_code = ?", o.organization_code },
           primary_key: :name, foreign_key: :lecturer_name

end
