class UserCartItem < ActiveRecord::Base
  belongs_to :user, counter_cache: :cart_items_count
  belongs_to :book
  belongs_to :course

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :price,
           to: :book, prefix: true, allow_nil: true
  delegate :organization_code, :department_code, :lecturer_name,
           :year, :term, :name, :code, :url, :required, :book_isbn,
           to: :course, prefix: true, allow_nil: true

  def price
    book.price * quantity
  end
end
