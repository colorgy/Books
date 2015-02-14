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

  describe ".check_cart" do
    it "destroys invalid cart items" do
      user = create(:user)

      book = create(:book)
      course = create(:course, :current, book_isbn: book.isbn)
      user.add_to_cart(book, course)
      valid_item_1 = user.cart_items.last

      book = create(:book)
      course = create(:course, :current)
      user.add_to_cart(book, course)
      valid_item_2 = user.cart_items.last

      course = create(:course, :current, book_isbn: book.isbn)
      user.add_to_cart(-999, course)
      invalid_item_1 = user.cart_items.last

      user.add_to_cart(-9999, -9999)
      invalid_item_2 = user.cart_items.last

      book = create(:book)
      course = create(:course, year: 1945, book_isbn: book.isbn)
      user.add_to_cart(book, course)
      invalid_item_3 = user.cart_items.last

      expect(user.cart_items.count).to eq(5)
      expect(user.cart_items_count).to eq(5)

      user.check_cart!

      expect(user.cart_items_count).to eq(2)
      expect(user.cart_items_count).to eq(2)
      expect(user.cart_items).to include(valid_item_1)
      expect(user.cart_items).to include(valid_item_2)
      expect(user.cart_items).not_to include(invalid_item_1)
      expect(user.cart_items).not_to include(invalid_item_2)
      expect(user.cart_items).not_to include(invalid_item_3)
    end
  end
end
