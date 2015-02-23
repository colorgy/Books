require 'rails_helper'

RSpec.describe Book, :type => :model do
  it_should_behave_like "an acts_as_paranoid model"
  it { should belong_to(:data) }
  it { should validate_presence_of(:data) }
end
