require 'rails_helper'

RSpec.describe User, :type => :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  context 'user confirm a course' do
    let(:course) { create(:course) }
    let(:user) { create(:user) } 

    it "cannot confirm course if book_data not assigned" do
      expect { course.confirm!(user) }.to raise_exception
    end

    it "can confirm course after assigned book_data" do
      course.book_data = create(:book_data)
      expect(course.confirmed_at).not_to be_nil
      expect { course.confirm!(user) }.not_to raise_exception
    end
  end

end
