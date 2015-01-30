FactoryGirl.define do
  factory :book do
    price { Faker::Commerce.price }
  end

end
