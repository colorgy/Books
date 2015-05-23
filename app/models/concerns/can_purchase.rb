module CanPurchase
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, class_name: :UserCartItem
    has_many :orders
    has_many :bills
  end

  # Adds an item into the user's cart
  #
  # Params:
  #
  # +item_type+::
  #   +String+ the type of item, +group+ for following a group, or +book+ for
  #   directly purchasing a book.
  #
  # +item_code+::
  #   +String+ the group code for following a group, or a id of the book to
  #   purchase directly.
  def add_to_cart(item_type, item_code, quantity: 1)
    existed_item = cart_items.find_by(item_type: item_type, item_code: item_code)
    if existed_item.existed
      existed_item.quantity += quantity
      existed_item.save!
    else
      cart_items.create!(item_type: item_type, item_code: item_code, quantity: quantity)
    end
    check_cart!
  end

  # Modify the quantity of an cart item
  def edit_cart(item_id, quantity: 1)
    quantity = 1 if quantity < 1
    cart_items.find(item_id).update!(quantity: quantity)
  end

  # Check the user's cart, log the name and price of an item into the db column
  # for faster queries later on. This also removes invalid items in the cart,
  # e.g.: deleted books, books for an organization that the user is not in, and
  # ended groups.
  # TODO: Implement `when 'book'`
  def check_cart!
    ActiveRecord::Base.transaction do
      # for each item in the cart
      cart_items.find_each do |item|
        case item.item_type
        when 'group'
          group = Group.find_by(code: item.item_code)
          # remove items that has ended or deleted
          if group.blank? || group.state != 'grouping'
            item.destroy
            next
          end
          # remove items that is not in the user's organization
          if group.organization_code != self.organization_code
            item.destroy
            next
          end
          # updates the item's name and price
          item.item_price = group.book.price
          item.item_name = "#{group.book.name} (#{group.book.isbn}) - #{group.pickup_datetime.strftime('%-m/%-d')}"
          item.save!
        end
      end
    end
    reload
    cart_items
  end

  # Clears all the items in the user's cart
  def clear_cart!
    cart_items.destroy_all
    reload
  end

  # Calculate the total price in the user's cart
  def cart_total_price
    price = 0
    cart_items.each do |item|
      price += item.price
    end
    price
  end

  # Checkout, returns the unsaved orders and bill that should be created
  def checkout(bill_attrs = {})
    check_cart!
    return { orders: [], bill: nil } unless Settings.open_for_orders
    orders = []
    total_price = 0
    bill = self.bills.build(bill_attrs)

    cart_items.each do |item|
      (item.quantity || 1).times do
        order = self.orders.build(
          bill: bill,
          book_id: item.book_id,
          course_id: item.course_id)
        total_price += order.price
        orders << order
      end
    end

    bill.price = total_price

    if credits > 0 && bill.amount > 100
      use_credits = (credits < (bill.amount - 100)) ? credits : (bill.amount - 100)
      bill.used_credits = use_credits
    end

    bill.calculate_amount

    reload

    { orders: orders, bill: bill }
  end

  # Checkout, returns the created orders and bill
  # TODO: Implement it
  def checkout!(bill_attrs = {})
  end
end
