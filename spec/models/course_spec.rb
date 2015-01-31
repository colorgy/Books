require 'rails_helper'

RSpec.describe Course, :type => :model do
  it { should belong_to(:book_data) }
  it { should belong_to(:lecturer_identity) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:lecturer_name) }

  describe "#book_name" do
    subject(:course) { create(:course, :with_book) }

    it "returns the book's name or the unknown_book_name" do
      expect(course.book_name).to eq course.book_data.name
      course.book_isbn = nil
      course.unknown_book_name = "A Book"
      expect(course.book_name).to eq "A Book"
    end
  end

  describe "#confirm_book!" do
    subject(:course) { create(:course) }

    it "confirms the assigned book" do
      expect do
        course.confirm_book!
      end.to change { course.book_confirmed? }.from(false).to(true)
      course.reload
      expect(course).to be_book_confirmed
    end
  end
end
