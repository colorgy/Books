class UpdateUserCartItems < ActiveRecord::Migration
  def change
    remove_column :user_cart_items, :book_id
    remove_column :user_cart_items, :course_id
    add_column :user_cart_items, :item_type, :string
    add_column :user_cart_items, :item_code, :string
    add_column :user_cart_items, :item_name, :string
    add_column :user_cart_items, :item_link, :string
    add_column :user_cart_items, :item_price, :integer
  end
end
