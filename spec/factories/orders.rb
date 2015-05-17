FactoryGirl.define do
  factory :order do
    book
    user { (User.count > 100) ? User.all.sample : create(:user) }
    course
    bill

    after(:create) do |order, evaluator|
      order.bill_created!
    end
  end
end
