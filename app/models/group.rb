class Group < ActiveRecord::Base
  belongs_to :leader, class_name: User, primary_key: :id, foreign_key: :leader_id
  has_many :orders, primary_key: :code, foreign_key: :group_code

  delegate :name, :avator, :fbid, :gender,
           to: :leader, prefix: true, allow_nil: true

  validates :code, presence: true
end
