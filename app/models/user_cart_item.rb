class UserCartItem < ActiveRecord::Base
  belongs_to :user, counter_cache: :cart_items_count

  validates :user, :item_type, :item_code, :quantity, presence: true
  validates :item_type, inclusion: { in: %w(group) }

  def price
    (book.try(:price) || 0) * quantity
  end
end
