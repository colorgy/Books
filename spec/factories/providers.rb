FactoryGirl.define do
  factory :provider do
    provider_code { %w(prov_a prov_b prov_c prov_d).sample }

    username { Faker::Internet.user_name }
    sequence(:email) { |n| "#{username}#{n}@#{provider_code}.com" }
    password { Faker::Internet.password }
    password_confirmation { password }

    trait :admin do
      admin true
    end
  end
end
