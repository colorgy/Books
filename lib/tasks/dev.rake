require "factory_girl"

namespace :dev do
  desc "Seed data for development environment"
  task prime: "db:setup" do

    if Rails.env.development?
      include FactoryGirl::Syntax::Methods

      FactoryGirl.create_list(:book_data, 50)

      FactoryGirl.create_list(:course, 20, :with_book)
      FactoryGirl.create_list(:course, 20, :with_book, confirmed_at: Time.now)
      FactoryGirl.create_list(:course, 20)
      FactoryGirl.create_list(:course, 10, :with_book, confirmed_at: Time.now)

      BookData.all.each do |book_data|
        if [true, false].sample
          FactoryGirl.create(:book, data: book_data, price: Faker::Commerce.price, supplier_code: %w(supplier_a supplier_b supplier_c supplier_d).sample)
        end
      end
    end
  end
end
