FactoryGirl.define do
  factory :book_data do
    isbn { Faker::Code.isbn }
    name { Faker::Company.name }
    edition { Faker::Number.digit }
    author { Faker::Name.name }
    image_url "http://placehold.it/400x500"
    url { Faker::Internet.url }
    publisher { Faker::Company.name }
    original_price { Faker::Commerce.price }
  end
end
