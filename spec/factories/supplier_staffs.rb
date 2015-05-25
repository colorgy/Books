FactoryGirl.define do
  factory :supplier_staff do
    supplier_code { %w(supplier_a supplier_b supplier_c supplier_d).sample }

    username { Faker::Internet.user_name }
    sequence(:email) { |n| "#{username}#{n}@#{supplier_code}.com" }
    password { Faker::Internet.password }
    password_confirmation { password }

    name { Faker::Name.name }

    trait :admin do
      admin true
    end
  end
end
