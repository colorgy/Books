FactoryGirl.define do
  factory :tutor_abc_form do
    mobile_phone_number "09123456789"
    if_heard_tutor_abc { false }
    user_id 1
  end

end
