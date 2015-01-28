require 'rails_helper'

RSpec.describe BookData, :type => :model do
  it { should respond_to(:book) }
  # it { should have_many(:courses) }
  it { should validate_uniqueness_of(:isbn) }

  it "validates isbn" do
    bookdata = create(:book_data)
    bookdata.isbn = "1234567890"
    expect(bookdata).not_to be_valid
  end

end
