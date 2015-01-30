FactoryGirl.define do
  factory :book do
    data { create(:book_data) }
    price { Faker::Commerce.price }
  end
end
