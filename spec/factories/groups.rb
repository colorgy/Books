FactoryGirl.define do
  factory :group do
    leader { create(:user) }
    course
    book

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
