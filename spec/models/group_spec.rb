require 'rails_helper'

RSpec.describe Group, :type => :model do
  it { should have_many(:orders) }
  it { should belong_to(:leader) }
  it { should validate_presence_of(:code) }
  it { should validate_presence_of(:book) }
  it { should validate_presence_of(:leader) }

  context "created" do
    subject { create(:group) }
    its(:code) { should_not be nil }
    its(:state) { should_not be nil }
    its(:shipped_at) { should be nil }
    its(:received_at) { should be nil }
  end

  describe "#ship!" do
    subject(:group) { create(:group, :with_orders) }

    it "sets shipped_at" do
      group.ship!
      expect(group.shipped_at).not_to be nil
    end

    it "mark its paid orders as shipped" do
      group.ship!
      group.orders.each do |order|
        expect(order.state).not_to eq('paid')
      end
    end

    context "already shipped" do
      before do
        group.ship!
      end
      it "does nothing" do
        expect { group.ship! }.to_not change { group.shipped_at }
      end
    end
  end

  describe "#receive!" do
    subject(:group) { create(:group, :with_orders) }
    before do
      group.ship!
    end

    it "sets shipped_at" do
      group.receive!
      expect(group.received_at).not_to be nil
    end

    it "mark its shpied orders as leader_received" do
      group.receive!
      group.orders.each do |order|
        expect(order.state).not_to eq('shipped')
      end
    end

    context "not shipped" do

      it "does nothing" do
        expect { group.ship! }.to_not change { group.shipped_at }
      end
    end
  end
end
