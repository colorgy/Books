require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should have_many(:identities) }
  it { should have_many(:cart_items) }

  describe ".add_to_cart" do
    it "adds a book to the user's cart" do
      user = create(:user)

      book = create(:book)
      course = create(:course, book_isbn: book.isbn)
      user.add_to_cart(book, course)
      expect(user.cart_items.includes(:book).map(&:book)).to include(book)
      expect(user.cart_items_count).to eq(1)

      book = create(:book)
      course = create(:course, book_isbn: book.isbn)
      user.add_to_cart(book, course)
      expect(user.cart_items.includes(:book).map(&:book)).to include(book)
      expect(user.cart_items_count).to eq(2)

      expect(user.cart_items.count).to eq(2)
    end
  end
end
