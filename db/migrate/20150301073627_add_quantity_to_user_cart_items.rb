class AddQuantityToUserCartItems < ActiveRecord::Migration
  def change
    add_column :user_cart_items, :quantity, :integer, null: false, default: 1
  end
end
