class UserCartItem < ActiveRecord::Base
  belongs_to :user, counter_cache: :cart_items_count
  belongs_to :item, polymorphic: true, foreign_key: :item_code

  validates :user, :item_type, :item_code, :quantity, presence: true
  validates :item_type, inclusion: { in: %w(group) }

  def item_price
    price * quantity
  end
end
