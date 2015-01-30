require 'rails_helper'

RSpec.describe User, :type => :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  context 'user confirm a course' do
    let(:course) { create(:course) }
    let(:user) { create(:user) } 

    it "cannot confirm course" do 
      expect { course.confirm!(user) }.to change{ course.confirmed? }.from(false).to(true)
      expect(course.user).to eq(user)
    end
  end

end
