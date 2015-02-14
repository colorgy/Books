require 'rails_helper'

RSpec.describe Order, :type => :model do
  let(:user) { create(:user, :with_items_in_cart) }
  subject(:order) do
    Settings.open_for_orders = true
    checkout_data = user.checkout
    checkout_data[:orders].last.save!
    checkout_data[:orders].last
  end

  describe "#state" do
    context "just created" do
      its(:state) { is_expected.to eq('new') }
    end
  end
end
