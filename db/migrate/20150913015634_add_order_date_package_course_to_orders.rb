class AddOrderDatePackageCourseToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_date, :date
    add_column :orders, :package_course_ucode, :string
  end
end
