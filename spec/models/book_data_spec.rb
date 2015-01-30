require 'rails_helper'

RSpec.describe BookData, :type => :model do
  it { should respond_to(:book) }
  it { should have_many(:courses) }
  it { should validate_uniqueness_of(:isbn) }

  it "validates isbn" do
    book_data = create(:book_data)
    book_data.isbn = "1234567890"
    expect(book_data).not_to be_valid
  end

  context 'a book_data has many courses' do
    let(:book_data) { create(:book_data_with_courses) }

    it "has a course" do
      book_data.courses.each {|c| expect(c.book_data).to eq(book_data) }
    end
  end

end
