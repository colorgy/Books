class User < ActiveRecord::Base
  devise :trackable, :timeoutable,
         :omniauthable, :omniauth_providers => [:colorgy]

  has_many :identities, class_name: :UserIdentity
  has_many :cart_items, class_name: :UserCartItem
  has_many :orders

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

  def add_to_cart(book, course)
    reutrn false if cart_items_count > 100
    book = book.id if book.respond_to? :id
    course = course.id if course.respond_to? :id

    is_created = cart_items.create(book_id: book, course_id: course)
    reload
    is_created
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

  def checkout(bill_attrs = {})
    check_cart!
    return { orders: [], bill: nil } unless Settings.open_for_orders
    orders = []

    cart_items.each do |item|
      orders << self.orders.build(book_id: item.book_id, course_id: item.course_id)
    end

    bill = nil#self.bills.build(bill_attrs)

    reload

    { orders: orders, bill: bill }
  end
end
