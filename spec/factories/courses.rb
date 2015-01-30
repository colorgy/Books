FactoryGirl.define do
  factory :course do
    organization_code { Faker::Company.name }
    department_code { Faker::Company.name }
    lecturer_name { Faker::Name.name }

    year { Faker::Time.between(5.years.ago, Time.now).year }
    term { [1, 2].sample }
    name { Faker::Company.name }
    code { Faker::Address.building_number }
    url { Faker::Internet.url }
    required { [true, false].sample }

    trait :with_book do
      book_isbn { Faker::Code.isbn }

      after(:build) do |course, evaluator|
        create(:book_data, isbn: evaluator.book_isbn)
      end
    end
  end
end
