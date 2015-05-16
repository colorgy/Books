module CanPurchase
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, class_name: :UserCartItem
    has_many :orders
    has_many :bills
  end

  def add_to_cart(book_id, course_id, quantity = 1)
    reutrn false if cart_items_count > 100
    book_id = book_id.id if book_id.respond_to? :id
    course_id = course_id.id if course_id.respond_to? :id

    new_item = cart_items.build(book_id: book_id, course_id: course_id, quantity: quantity)
    reload and return false if cart_total_price > 18_000
    saved = new_item.save!
    reload
    saved
  end

  def check_cart!
    ActiveRecord::Base.transaction do
      cart_items.includes(:book, :course).find_each do |item|
        if !(item.course && item.course.current?)
          item.destroy!
        end
        if !(item.book)
          item.destroy!
        end
      end
    end
    reload
    cart_items
  end

  def clear_cart!
    cart_items.destroy_all
    reload
  end

  def cart_total_price
    price = 0
    cart_items.each do |item|
      price += item.price
    end
    price
  end

  def checkout(bill_attrs = {})
    check_cart!
    return { orders: [], bill: nil } unless Settings.open_for_orders
    orders = []
    total_price = 0

    cart_items.each do |item|
      (item.quantity || 1).times do
        order = self.orders.build(book_id: item.book_id, course_id: item.course_id)
        total_price += order.price
        orders << order
      end
    end

    bill_attrs[:price] = total_price

    bill = self.bills.build(bill_attrs)

    if credits > 0 && bill.amount > 100
      use_credits = (credits < (bill.amount - 100)) ? credits : (bill.amount - 100)
      bill.amount -= use_credits
      bill.used_credits = use_credits
    end

    reload

    { orders: orders, bill: bill }
  end
end
