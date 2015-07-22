class AddCourseUcodeToUserCartItemsAndOrders < ActiveRecord::Migration
  def change
    add_column :orders, :course_ucode, :string
    add_column :user_cart_items, :course_ucode, :string
  end
end
