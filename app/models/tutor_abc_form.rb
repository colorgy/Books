class TutorAbcForm < ActiveRecord::Base
	belongs_to :user
	validates :mobile_phone_number, presence: true, length: { minimum: 10 }
	validates :if_heard_tutor_abc, presence: true
end
