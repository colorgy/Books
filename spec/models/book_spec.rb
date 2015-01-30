require 'rails_helper'

RSpec.describe Book, :type => :model do
  it { should belong_to(:data) }
  it { should validate_presence_of(:data) }
end
