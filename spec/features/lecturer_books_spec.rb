require 'rails_helper'

feature "The lecturer-books registration", :type => :feature do
  before do
    @eula = Faker::Lorem.paragraph
    Settings[:site_eula] = @eula
  end

  scenario "User registers books", js: true do
    visit(lecturer_books_path)
    expect(page).to have_content('歡迎使用')
    # TODO: write tests
  end
end
