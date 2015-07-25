class AddIsRootToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :is_root, :boolean, null: false, default: false
    add_column :suppliers, :deal_package, :boolean, null: false, default: false
  end
end
