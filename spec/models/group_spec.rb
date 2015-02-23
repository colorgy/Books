require 'rails_helper'

RSpec.describe Group, :type => :model do
  it { should have_many(:orders) }
  it { should belong_to(:leader) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:course) }
  it { should validate_presence_of(:book) }
end
