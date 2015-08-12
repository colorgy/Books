FactoryGirl.define do
  factory :package_additional_item do
    name { Faker::Company.name }
    price { Faker::Commerce.price }
    url "https://google.com"
    external_image_url "http://placehold.it/500x500"
  end
end
