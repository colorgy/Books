FactoryGirl.define do
  factory :user do
    sequence(:sid) { |n| "0#{n}" }
    sequence(:email) { |n| "#{Faker::Internet.user_name}#{n}@example.com" }
    name { Faker::Name.name }
    avatar_url "http://placehold.it/500x500"
    cover_photo_url "http://placehold.it/800x400"

    sequence(:uid) { |n| "u0#{n}" }
    identity 'student'

    trait :with_items_in_cart do
      cart_items_count 3

      after(:create) do |user, evaluator|
        evaluator.cart_items_count.times do
          book = create(:book)
          course = create(:course, :current, book_isbn: book.isbn)
          user.add_to_cart(book, course)
        end
      end
    end
  end
end
