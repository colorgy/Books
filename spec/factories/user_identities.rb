FactoryGirl.define do
  factory :user_identity do
    user
    organization_code { Faker::Company.name }
    department_code { Faker::Company.name }
    uid { Faker::Lorem.characters(10) }
    email { Faker::Internet.safe_email }
    identity { ['professor', 'lecturer', 'staff', 'student', 'guest'].sample }
    name { Faker::Name.name }
  end
end
