FactoryGirl.define do
  factory :order do
    book
    user
    course
    bill

    after(:create) do |order, evaluator|
      order.bill_created!
    end
  end
end
