RSpec.shared_examples "CanPurchase" do
  # it { should have_many(:cart_items) }
  # it { should have_many(:orders) }
  # it { should have_many(:bills) }

  # let(:user) { create(:user) }
  # let(:book) { create(:book) }
  # let(:group) { create(:group) }

  # describe "#add_to_cart" do
  #   it "adds a group to the user's cart" do
  #     user.add_to_cart(:group, group.code)
  #     expect(user.cart_items.first.item_type).to eq('group')
  #     expect(user.cart_items.first.item_code).to eq(group.code)
  #     expect(user.cart_items.first.quantity).to eq(1)

  #     # Automatically merges existing items
  #     user.add_to_cart(:group, group.code, quantity: 3)
  #     expect(user.cart_items.first.item_type).to eq('group')
  #     expect(user.cart_items.first.item_code).to eq(group.code)
  #     expect(user.cart_items.first.quantity).to eq(4)
  #   end

  #   xit "adds a book to the user's cart" do
  #     # Item count lower then the minimum purchase amount will be rejected
  #     user.add_to_cart(:book, book.id, quantity: 1)
  #     expect(user.cart_items.first).to be nil

  #     # Item count equals the minimum purchase amount is okay
  #     user.add_to_cart(:book, book.id, quantity: book.minimum_purchase_quantity)
  #     expect(user.cart_items.first.item_type).to eq('book')
  #     expect(user.cart_items.first.item_code).to eq(book.id)
  #     expect(user.cart_items.first.quantity).to eq(book.minimum_purchase_quantity)

  #     # Automatically merges existing items
  #     user.add_to_cart(:book, book.id, quantity: 10)
  #     expect(user.cart_items.first.item_type).to eq('book')
  #     expect(user.cart_items.first.item_code).to eq(book.id)
  #     expect(user.cart_items.first.quantity).to eq(book.minimum_purchase_quantity + 10)
  #   end

  #   it "raise error if an invalid item_type is given" do
  #     expect do
  #       user.add_to_cart(:blas, 'xxxx')
  #     end.to raise_error
  #   end

  #   it "ignores non-existing group" do
  #     user.add_to_cart(:group, 'non_existing_group_code')
  #     expect(user.cart_items.first).to be nil
  #   end

  #   it "ignores not-grouping group" do
  #     group.end!
  #     user.add_to_cart(:group, group.code)
  #     expect(user.cart_items.first).to be nil
  #   end

  #   xit "ignores non-existing book" do
  #     user.add_to_cart(:book, 'non_existing_book_id')
  #     expect(user.cart_items.first).to be nil
  #   end
  # end

  # describe "#clear_cart!" do
  #   before do
  #     user.add_to_cart(:group, group.code)
  #   end

  #   it "clears the user's cart" do
  #     expect(user.cart_items).not_to be_blank
  #     user.clear_cart!
  #     expect(user.cart_items).to be_blank
  #   end
  # end

  # describe "#edit_cart" do
  #   before do
  #     user.add_to_cart(:group, group.code)
  #   end

  #   it "clears the user's cart" do
  #     expect(user.cart_items.last.quantity).to eq(1)
  #     user.edit_cart(user.cart_items.last.id, quantity: 15)
  #     expect(user.cart_items.last.quantity).to eq(15)
  #     user.edit_cart(user.cart_items.last.id, quantity: 5)
  #     expect(user.cart_items.last.quantity).to eq(5)
  #   end
  # end

  # describe "#remove_cart_item" do
  #   before do
  #     user.add_to_cart(:group, group.code)
  #   end

  #   xit "removes an item in the user's cart" do
  #     expect(user.cart_items).not_to be_blank
  #     user.remove_cart_item(user.cart_items.last.id)
  #     expect(user.cart_items).to be_blank
  #   end
  # end
end
