require 'rails_helper'

RSpec.describe Course, :type => :model do
  it { should belong_to(:book_data) }
  it { should belong_to(:lecturer_identity) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:lecturer_name) }

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
