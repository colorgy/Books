FactoryGirl.define do
  factory :group do
    book { create(:book) }
    leader { create(:user, organization_code: book.organization_code) }
    public true

    course nil
    organization_code { book.organization_code }

    pickup_datetime { Faker::Time.between(10.days.from_now, 1.month.from_now) }
    pickup_point { Faker::Address.street_address }
    recipient_name { Faker::Name.name }
    recipient_mobile { Faker::PhoneNumber.cell_phone }

    trait :in_org do
      book { create(:book, organization_code: (Organization.example_cods + [nil]).sample) }
      organization_code { book.organization_code || Organization.example_cods.sample }
      leader { create(:user, organization_code: organization_code) }
    end

    # trait :with_course do
    #   course { book.organization_code.present? ? create(:course, organization_code: book.organization_code) : create(:course) }
    # end

    trait :with_orders do
      transient do
        orders_count 10
      end

      after(:create) do |group, evaluator|
        evaluator.orders_count.times do
          order = create(:group_order, group: group, quantity: [1, 1, 1, 2, 3].sample)
          order = order.first if order.is_a?(Array)
          order.bill.pay! if [true, true, false].sample
        end
        group.reload
      end
    end

    trait :ended do
      before(:build) { Timecop.travel(1.month.ago) }
      after(:create) do |group|
        Timecop.return
        group.pickup_datetime = Faker::Time.between(Time.now, 1.month.ago)
        group.set_deadline
        group.save!
        group.reload
        group.orders.each do |order|
          bill = order.bill
          bill.deadline = group.deadline
          bill.save!
        end
      end
    end
  end
end
