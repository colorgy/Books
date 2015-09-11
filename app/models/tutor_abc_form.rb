class TutorAbcForm < ActiveRecord::Base
	belongs_to :user
	validates :mobile_phone_number, presence: true, length: { minimum: 10 }
  validates_inclusion_of :if_heard_tutor_abc, :in => [true, false]
end
