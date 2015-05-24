FactoryGirl.define do
  factory :book do
    data { create(:book_data) }
    price { Faker::Commerce.price }
    provider { %w(prov_a prov_b prov_c prov_d).sample }
    organization_code nil
  end

  trait :in_org_and_pub do
    organization_code { Organization.example_cods.sample }

    after(:create) do |book, _|
      create(:book, isbn: book.isbn, price: book.price * 1.2, provider: book.provider, organization_code: nil)
    end
  end
end
