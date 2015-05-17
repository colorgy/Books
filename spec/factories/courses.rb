FactoryGirl.define do
  factory :course do
    lecturer_names = ['Prof A', 'Prof B', 'Prof C', 'Prof D', 'Prof E', 'Prof F', 'Prof G', 'Lecturer A', 'Lecturer B', 'Lecturer C', 'Lecturer D', 'Lecturer E', 'Lecturer F', 'Lecturer G']

    organization_code { Organization.example_cods.sample }
    department_code { Faker::Address.building_number }
    lecturer_name { lecturer_names.sample }

    year { Faker::Time.between(5.years.ago, Time.now).year }
    term { [1, 2].sample }
    name { Faker::Company.name }
    code { Faker::Address.building_number }
    url { Faker::Internet.url }
    required { [true, false].sample }
    unknown_book_name nil

    trait :current do
      year { BatchCodeService.current_year }
      term { BatchCodeService.current_term }
    end

    trait :with_book do
      book_isbn { Faker::Code.isbn }

      after(:build) do |_, evaluator|
        create(:book_data, isbn: evaluator.book_isbn)
      end
    end
  end
end
