require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should have_many(:identities) }
  it { should have_many(:cart_items) }
end
