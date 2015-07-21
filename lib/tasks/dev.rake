require "factory_girl"

namespace :dev do
  desc "Seed data for development environment"
  task prime: "db:setup" do

    if Rails.env.development?
      include FactoryGirl::Syntax::Methods

      create_list(:book_data, 50)

      BookData.all.each do |book_data|
        if [true, true, false].sample
          create(:book, data: book_data, price: book_data.original_price * 0.8, supplier_code: %w(supplier_a supplier_b supplier_c supplier_d).sample)
        end
      end

      create_list(:course, 100)
      create_list(:course, 300, year: DatetimeService.current_year, term: DatetimeService.current_term)

      Course.all.each do |course|
        if [true, true, true, true, true, true, true, false].sample
          course.book_data << BookData.order('RANDOM()').first
        end
      end

      create(:supplier, name: '第一書局', code: 'supplier_a')
      create(:supplier, name: '第二書局', code: 'supplier_b')
      create(:supplier, name: '第三書局', code: 'supplier_c')
      create(:supplier, name: '第四書局', code: 'supplier_d')

      create(:supplier_staff, supplier_code: 'supplier_a', username: 'a_admin', password: 'a_password')
      create(:supplier_staff, supplier_code: 'supplier_b', username: 'b_admin', password: 'b_password')
      create(:supplier_staff, supplier_code: 'supplier_c', username: 'c_admin', password: 'c_password')
      create(:supplier_staff, supplier_code: 'supplier_d', username: 'd_admin', password: 'd_password')
    end
  end
end
