class AddPackageIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :package_id, :integer
    add_index :orders, :package_id
  end
end
