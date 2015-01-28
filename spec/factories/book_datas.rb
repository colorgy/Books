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

    factory :book_data_with_courses do 
      transient do 
        courses_count 5
      end

      after(:create) do |book_data, evaluator|
        create_list(:course, evaluator.courses_count, book_data: book_data)
      end
    end
  end
end
