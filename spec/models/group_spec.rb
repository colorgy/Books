require 'rails_helper'

RSpec.describe Group, :type => :model do
  it { should have_many(:orders) }
  it { should belong_to(:leader) }
  it { should validate_presence_of(:code) }
end
