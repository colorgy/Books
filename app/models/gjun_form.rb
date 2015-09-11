class GjunForm < ActiveRecord::Base
	belongs_to :user
	validates :mobile_phone_number, presence: true, length: { minimum: 10 }
  validates_inclusion_of :if_heard_gjun, :in => [true, false]
end
