require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should have_many(:identities) }
  it { should have_many(:cart_items) }
  it { should have_many(:orders) }
  it { should have_many(:bills) }
  it { should have_many(:lead_groups) }
  # it { should have_many(:groups) }

  describe "#add_to_cart" do
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

  describe "#check_cart" do
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

  describe "#clear_cart!" do
    it "destroys every item in the user's cart" do
      user = create(:user)

      book = create(:book)
      course = create(:course, :current, book_isbn: book.isbn)
      user.add_to_cart(book, course)
      user.add_to_cart(book, course)
      user.add_to_cart(book, course)
      expect(user.cart_items_count).to eq(3)
      expect(user.cart_items.count).to eq(3)

      user.clear_cart!
      expect(user.cart_items_count).to eq(0)
      expect(user.cart_items.count).to eq(0)
    end
  end

  describe "#checkout" do
    let(:user) { create(:user, :with_items_in_cart, cart_items_count: 4) }
    subject(:checkout_data) { user.checkout }

    context "not open_for_orders" do
      before do
        Settings.open_for_orders = false
      end

      it "returns nothing" do
        expect(checkout_data[:orders]).to be_blank
        expect(checkout_data[:bill]).to be_blank
      end
    end

    context "is open_for_orders" do
      before do
        Settings.open_for_orders = true
        Settings.order_batch = [1, 2, 3].sample
      end

      it "returns builded orders and a bill in hash" do
        expect(checkout_data[:orders]).not_to be_blank
        checkout_data[:orders].each_with_index do |order, i|
          expect(order).to be_valid
          expect(order.organization_code).to eq(user.cart_items[i].course.organization_code)
          expect(order.batch).to eq("#{Course.current_year}-#{Course.current_term}-#{Settings.order_batch}")
          expect(order.group_code).to eq("#{Course.current_year}-#{Course.current_term}-#{Settings.order_batch}-#{user.cart_items[i].course.organization_code}-#{user.cart_items[i].course.id}-#{user.cart_items[i].book.id}")
          expect(order.price).to eq(user.cart_items[i].book.price)
        end
      end
    end
  end

  describe "#add_credit" do
    let(:user) { create(:user) }
    it "adds credits to the user" do
      user.add_credit(37)
      expect(user.credits).to eq(37)
      user.reload
      expect(user.credits).to eq(0)

      user.add_credit!(120)
      expect(user.credits).to eq(120)
      user.reload
      expect(user.credits).to eq(120)
    end
  end

  describe "#use_credit" do
    let(:user) { create(:user) }
    it "deducts credits from the user" do
      user.add_credit!(100)

      user.use_credit(52)
      expect(user.credits).to eq(48)
      user.reload
      expect(user.credits).to eq(100)

      user.use_credit!(52)
      expect(user.credits).to eq(48)
      user.reload
      expect(user.credits).to eq(48)

      expect { user.use_credit(1000) }.to raise_error
    end
  end

  describe "#lead_course_group" do
    let(:user) { create(:user, :with_items_in_cart, cart_items_count: 4) }
    let(:course) { user.cart_items.first.course }
    let(:book) { user.cart_items.first.book }

    it "start to lead a group and earn credits" do
      expect(user.credits).to eq(0)
      user.lead_course_group(course.id, book.id)
      expect(user.credits).to eq(35)
      expect(Group.last.leader).to eq(user)

      user2 = create(:user)
      expect { user2.lead_course_group(course.id, book.id) }.to raise_error
      expect { user2.lead_course_group(1234, book.id) }.to raise_error
    end
  end
end
