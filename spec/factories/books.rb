FactoryGirl.define do
  factory :book do
    data { create(:book_data) }
    price { Faker::Commerce.price * 90 }
    supplier_code { %w(supplier_a supplier_b supplier_c supplier_d).sample }
    organization_code nil
  end

  trait :in_org_and_pub do
    organization_code { Organization.example_cods.sample }

    after(:create) do |book, _|
      create(:book, isbn: book.isbn, price: book.price * 1.2, supplier_code: book.supplier_code, organization_code: nil)
    end
  end
end
