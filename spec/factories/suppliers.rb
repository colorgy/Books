FactoryGirl.define do
  factory :supplier do
    name { Faker::Company.name }
    code { name.underscore }
  end
end
