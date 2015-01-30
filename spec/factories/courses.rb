FactoryGirl.define do
  factory :course do
    name { Faker::Company.name } 
    description { Faker::Lorem.paragraph }
    credits { Faker::Number.between(0, 4) }
    url { Faker::Internet.url }
  end
end
