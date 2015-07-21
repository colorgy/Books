class UserCartItem < ActiveRecord::Base
  belongs_to :user, counter_cache: :cart_items_count

  validates :user, :item_type, :item_code, :quantity, presence: true
  validates :quantity, inclusion: 1..100
  validates :item_type, inclusion: { in: %w(group package) }

  # Return the corresponding group
  def group
    return nil if item_type != 'group'
    @group ||= Group.where(code: item_code).last
  end

  # Return the corresponding item (group or book)
  def item
    case item_type
    when 'group'
      group
    end
  end

  # def item_price
  #   price * quantity
  # end
end
