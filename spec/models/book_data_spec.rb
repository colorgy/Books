require 'rails_helper'

RSpec.describe BookData, :type => :model do
  it { should have_one(:book) }
  it { should have_many(:courses) }

  it "validates uniqueness of isbn" do
    create(:book_data, isbn: '978-0-123456-47-2')
    book_data = build(:book_data, isbn: '978-0-123456-47-2')
    expect(book_data).not_to be_valid
  end

  # it "validates validity of isbn" do
  #   book_data = create(:book_data)
  #   book_data.isbn = "1234567890"
  #   expect(book_data).not_to be_valid
  # end

  describe "instantiation" do
    subject(:book_data) { create(:book_data, :with_courses) }

    it "has relation to many course" do
      book_data.courses.each { |c| expect(c.book_data).to eq(book_data) }
    end
  end
end
