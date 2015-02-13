require 'rails_helper'

RSpec.describe UserCartItem, :type => :model do
  it { should belong_to(:user) }
  it { should belong_to(:book) }
  it { should belong_to(:course) }
end
