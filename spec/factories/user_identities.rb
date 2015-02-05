FactoryGirl.define do
  factory :user_identity do
    user
    organization_code { Faker::Company.name.gsub(/[^A-Z0-9]/, '') }
    department_code { Faker::Address.building_number }
    uid { Faker::Lorem.characters(10) }
    email { Faker::Internet.safe_email }
    identity { %w(professor lecturer staff student guest).sample }
    name { Faker::Name.name }
  end
end
