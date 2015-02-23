class AddCartItemsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cart_items_count, :integer, default: 0
  end
end
