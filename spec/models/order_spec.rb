require 'rails_helper'

RSpec.describe Order, :type => :model do
  it { should belong_to(:user) }
  it { should belong_to(:course) }
  it { should belong_to(:book) }
  it { should belong_to(:bill) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:course) }
  it { should validate_presence_of(:book) }

  let(:user) { create(:user, :with_items_in_cart) }
  subject(:order) do
    Settings.open_for_orders = true
    checkout_data = user.checkout
    checkout_data[:orders].last.save!
    checkout_data[:orders].last
  end

  context "just created" do
    its(:state) { is_expected.to eq('new') }
  end
end
