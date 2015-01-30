FactoryGirl.define do
  factory :user do
    sequence(:sid) { |n| "0#{n}" }
    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    name { Faker::Name.name }
    avatar_url "http://placehold.it/500x500"
    cover_photo_url "http://placehold.it/800x400"

    sequence(:uid) { |n| "u0#{n}" }
    identity 'student'
  end

end
