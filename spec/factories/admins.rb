FactoryGirl.define do
  factory :admin do
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { SecureRandom.hex(20) }
  end

end
