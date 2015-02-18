require 'rails_helper'

RSpec.describe Bill, :type => :model do
  it { should belong_to(:user) }
  it { should have_many(:orders) }
  it { should validate_inclusion_of(:type).in_array(%w(payment_code credit_card virtual_account)) }
  it { should validate_inclusion_of(:invoice_type).in_array(%w(digital paper code love_code uni_num)) }
  it { should validate_presence_of(:uuid) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:type) }
  it { should validate_presence_of(:price) }
  it { should validate_presence_of(:amount) }
  it { should validate_presence_of(:state) }
  it { should validate_presence_of(:invoice_type) }

  let(:user) { create(:user, :with_items_in_cart) }
  before do
    @bill_params = { type: 'credit_card', invoice_type: 'digital' }
    Bill.test = true
  end
  subject(:bill) do
    Settings.open_for_orders = true
    checkout_data = user.checkout(@bill_params)
    ActiveRecord::Base.transaction do
      checkout_data[:bill].save!
      checkout_data[:orders].each do |order|
        order.save_with_bill!(checkout_data[:bill])
      end
    end
    checkout_data[:bill]
  end

  context "just created" do
    its(:state) { is_expected.to eq('payment_pending') }
    its(:uuid) { is_expected.not_to be_blank }
    its(:amount) { is_expected.to eq(bill.price) }
  end

  context "using payment_code" do
    before do
      @bill_params = { type: 'payment_code', invoice_type: 'digital' }
    end
    its(:amount) { is_expected.to eq(bill.price + 35) }
  end

  describe ".pay!" do
    it "marks itself as paid" do
      expect(bill).not_to be_paid
      bill.pay!
      expect(bill).to be_paid
      expect(bill.versions.count).to eq(2)
    end

    it "sets the paid time" do
      expect(bill).not_to be_paid
      bill.pay!
      expect(bill.paid_at).not_to be_blank
      bill.reload
      expect(bill.paid_at).not_to be_blank
    end

    it "marks its orders as paid" do
      expect(bill.orders).not_to be_blank
      bill.orders.each do |order|
        expect(order).not_to be_paid
      end
      bill.pay!
      bill.orders.each do |order|
        expect(order).to be_paid
        expect(order.versions.count).to eq(2)
      end
    end
  end
end
