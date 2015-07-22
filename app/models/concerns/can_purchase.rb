module CanPurchase
  extend ActiveSupport::Concern

  included do
    has_many :cart_items, class_name: :UserCartItem
    has_many :orders
    has_many :packages
    has_many :bills
  end

  # Adds an item into the user's cart
  #
  # Params:
  #
  # +item_type+::
  #   +String+ the type of item, +group+ for following a group, +package+ for
  #   package, or +book+ for directly purchasing a book.
  #
  # +item_code+::
  #   +String+ the group code for following a group, or a id of the book to
  #   purchase directly.
  def add_to_cart(item_type, item_code, quantity: 1, course_ucode: nil)
    quantity = quantity.to_i
    existed_item = cart_items.find_by(item_type: item_type, item_code: item_code)
    if existed_item.present?
      existed_item.quantity += quantity
      existed_item.course_ucode = course_ucode if course_ucode.present?
      existed_item.save!
    else
      case item_type.to_sym
      when :group
        cart_items.create!(item_type: item_type, item_code: item_code, quantity: quantity)
      when :package
        cart_items.create!(item_type: item_type, item_code: item_code, quantity: quantity, course_ucode: course_ucode)
      else
        raise 'invalid item_type'
      end
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
  def check_cart!
    ActiveRecord::Base.transaction do
      # for each item in the cart
      cart_items.includes_default.find_each do |item|
        case item.item_type
        when 'group'
          group = item.group
          # remove groups that is not grouping
          if group.blank? || group.state != 'grouping'
            item.destroy
            next
          end
          # remove groups that is not in the user's organization
          if group.organization_code != self.organization_code
            item.destroy
            next
          end
          # updates the item's name and price
          item.item_price = group.book.price
          item.item_name = "#{group.book.name} (#{group.book.isbn}) - #{group.pickup_datetime.strftime('%-m/%-d')}"
          item.save!
        when 'package'
          book = Book.for_org(self.organization_code).find_by(id: item.item_code)
          # remove items with non-existing book
          if book.blank?
            item.destroy
            next
          end
          # updates the item's name and price
          item.item_price = book.price
          item.item_name = "#{book.name} (#{book.isbn}) - 包裹專送"
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

  # Pre-checkout, returns the unsaved orders and bill that should be created
  def checkout(bill_attrs = {}, package_attrs: {})
    check_cart!
    return { orders: [], bill: nil } unless Settings.open_for_orders
    return { orders: [], bill: nil } if cart_items.blank?

    # start to build the orders and the bill
    orders = []
    total_price = 0
    bill = self.bills.build(bill_attrs)
    package = nil

    # proceed each cart item
    cart_items.each do |item|
      case item.item_type
      when 'group'
        group = item.group
        bill.deadline = group.deadline if bill.deadline.blank? ||
                                          bill.deadline > group.deadline
        (item.quantity || 1).times do
          order = self.orders.build(
            bill: bill,
            book_id: group.book_id,
            course_ucode: group.course_ucode,
            group: group)
          total_price += order.price
          orders << order
        end
      when 'package'
        package ||= self.packages.build(package_attrs)
        package.price ||= 0

        (item.quantity || 1).times do
          order = self.orders.build(
            bill: bill,
            book_id: item.item_code,
            course_ucode: item.course_ucode,
            package: package)
          package.price += order.price
          package.orders_count += 1
          orders << order
        end
      end
    end

    package.calculate_amount if package.present?

    bill.price = total_price

    bill.price += package.amount if package.present?

    if credits > 0 && bill.amount > 100
      use_credits = (credits < (bill.amount - 100)) ? credits : (bill.amount - 100)
      bill.used_credits = use_credits
    end

    bill.calculate_amount

    reload

    data = { orders: orders, bill: bill }

    if package.present?
      data[:package] = package
    end

    data
  end

  # Checkout, clears the cart, and return the created orders and bill
  def checkout!(bill_attrs = {}, package_attrs: {})
    checkouts = checkout(bill_attrs, package_attrs: package_attrs)
    return checkouts if checkouts[:bill].blank?
    transaction do
      checkouts[:bill].save!
      checkouts[:package].save! if checkouts[:package]
      checkouts[:orders].each(&:save!)
      clear_cart!
    end
    checkouts
  end
end
