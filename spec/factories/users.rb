FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    name { Faker::Name.name }
  end

end
