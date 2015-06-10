class AddOrdersCountToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :orders_count, :integer, null: false, default: 0
    add_column :groups, :unpaid_orders_count, :integer, null: false, default: 0
  end
end
