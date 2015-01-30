require 'rails_helper'

RSpec.describe UserIdentity, :type => :model do
  it { should belong_to(:user) }
  it { should have_many(:courses) }

  it "should have many courses in the same organization" do
    user_identity = create(:user_identity)
    course_in_org = create(:course, lecturer_name: user_identity.name, organization_code: user_identity.organization_code)
    course_in_other_org = create(:course, lecturer_name: user_identity.name, organization_code: "ANOTHERORG")

    expect(user_identity.courses).to include(course_in_org)
    expect(user_identity.courses).not_to include(course_in_other_org)

  end

  describe ".lecturer" do
    it "scopes the professor and lecturer" do
      create_list(:user_identity, 30)
      UserIdentity.lecturer.each do |ui|
        expect(ui.identity).to satisfy { |i| %w(professor lecturer).include?(i) }
      end
    end
  end
end
