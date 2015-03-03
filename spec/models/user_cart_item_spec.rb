require 'rails_helper'

RSpec.describe UserCartItem, :type => :model do
  it { should belong_to(:user) }
  it { should belong_to(:book) }
  it { should belong_to(:course) }
  it { should validate_inclusion_of(:quantity).in_range(1..12) }

  describe "#price" do
    let(:user) { create(:user) }
    let(:course) { create(:course, :current) }
    let(:book) { create(:book) }

    it "returns the total price of the item" do
      quantity = [2, 3].sample
      user.add_to_cart(book, course, quantity)
      cart_item = user.cart_items.last
      expect(cart_item.price).to eq(book.price * quantity)
    end
  end
end
