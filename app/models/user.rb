class User < ActiveRecord::Base
  devise :trackable, :timeoutable,
         :omniauthable, :omniauth_providers => [:colorgy]

  has_many :identities, class_name: :UserIdentity
  has_many :cart_items, class_name: :UserCartItem
  has_many :orders
  has_many :bills
  has_many :lead_groups, class_name: Group, foreign_key: :leader_id
  # has_many :groups, through: :orders

  def self.from_core(auth)
    user = where(:sid => auth.info.id).first_or_create! do |new_user|
      new_user.email = auth.info.email
    end

    oauth_params = ActionController::Parameters.new(auth.info)

    attrs = %i(username gender username name avatar_url cover_photo_url gender fbid uid identity organization_code department_code)

    user_data = oauth_params.slice(*attrs).permit(*attrs)

    user_data['refreshed_at'] = Time.now
    user_data['core_access_token'] = auth.credentials.token

    user.update!(user_data)

    ActiveRecord::Base.transaction do
      user.identities.destroy_all

      identities = auth.info.identities
      identities_inserts = identities.map { |i| "(#{i[:id]}, #{user.id}, '#{i[:organization_code]}', '#{i[:department_code]}', '#{i[:name]}', '#{i[:uid]}', '#{i[:email]}', '#{i[:identity]}')" }
      if identities_inserts.length > 0
        sql = <<-eof
          INSERT INTO user_identities (sid, user_id, organization_code, department_code, name, uid, email, identity)
          VALUES #{identities_inserts.join(', ')}
        eof
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    return user
  end

  def add_to_cart(book, course, quantity)
    reutrn false if cart_items_count > 100
    book = book.id if book.respond_to? :id
    course = course.id if course.respond_to? :id
    quantity = [1, quantity].max
    quantity = [12, quantity].min

    ActiveRecord::Base.transaction do
      created_item = cart_items.create(book_id: book, course_id: course, quantity: quantity)
      reload
      if (cart_total_price > 18_000)
        created_item.destroy!
        reload
        nil
      else
        created_item
      end
    end
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
    check_cart!
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

  def add_credit(amount)
    self.credits += amount
  end

  def add_credit!(amount)
    add_credit(amount)
    save!
  end

  def use_credit(amount)
    self.credits -= amount
    raise 'not enough credits' if self.credits < 0
  end

  def use_credit!(amount)
    use_credit(amount)
    save!
  end

  def lead_course_group(course_id, book_id)
    course = Course.find(course_id)
    book = Book.find(book_id)
    group = nil

    ActiveRecord::Base.transaction do
      group = Group.create!(leader_id: id, code: Group.generate_code(course.organization_code, course.id, book.id), course: course, book: book)
      add_credit!(35)
    end

    group
  end
end
