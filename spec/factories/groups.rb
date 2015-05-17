FactoryGirl.define do
  factory :group do
    book { (Book.count > 1000) ? Book.all.sample : create(:book) }
    leader { (User.where(organization_code: book.organization_code).count > 100) ? User.where(organization_code: book.organization_code).sample : create(:user, organization_code: book.organization_code) }

    course nil
    organization_code { book.organization_code }

    pickup_point { Faker::Address.street_address }
    pickup_datetime { Faker::Time.between(7.months.ago, 7.months.from_now) }
    recipient_name { Faker::Name.name }
    recipient_mobile { Faker::PhoneNumber.cell_phone }

    trait :in_org do
      book { (Book.count > 1000) ? Book.all.sample : create(:book, organization_code: (Organization.example_cods + [nil]).sample) }
      organization_code { book.organization_code.present? ? book.organization_code : Organization.example_cods.sample }
      leader { (User.where(organization_code: organization_code).count > 100) ? User.where(organization_code: organization_code).sample : create(:user, organization_code: organization_code) }
    end

    trait :with_course do
      course { book.organization_code.present? ? create(:course, organization_code: book.organization_code) : create(:course) }
    end

    trait :with_orders do
      transient do
        orders_count 10
      end

      after(:create) do |group, evaluator|
        evaluator.orders_count.times do
          order = create(:order, group: group, book: group.book, course: group.course)
          order.bill.pay! if [true, true, false].sample
        end
      end
    end
  end
end
