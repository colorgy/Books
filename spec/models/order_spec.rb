require 'rails_helper'

RSpec.describe Order, :type => :model do
  it { should belong_to(:user) }
  it { should belong_to(:course) }
  it { should belong_to(:book) }
  it { should belong_to(:bill) }
  it { should belong_to(:group) }
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
    its(:batch) { is_expected.to eq("#{Course.current_year}-#{Course.current_term}-#{Settings.order_batch}") }
    its(:group_code) { is_expected.to eq("#{order.batch}-#{order.organization_code}-#{order.course.id}-#{order.book.id}") }
  end

  context "course changed" do
    before do
      expect(order.group_code).to eq("#{order.batch}-#{order.organization_code}-#{order.course.id}-#{order.book.id}")
      @another_course = create(:course)
      order.course = @another_course
      order.save!
    end
    its(:group_code) { is_expected.to eq("#{order.batch}-#{@another_course.organization_code}-#{@another_course.id}-#{order.book.id}") }
    its(:organization_code) { is_expected.to eq(@another_course.organization_code) }
  end
end
