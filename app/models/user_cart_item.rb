class UserCartItem < ActiveRecord::Base
  belongs_to :user, counter_cache: :cart_items_count
  belongs_to :book
  belongs_to :course
end
