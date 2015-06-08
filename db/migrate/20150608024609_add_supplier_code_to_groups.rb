class AddSupplierCodeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :supplier_code, :string
    add_index :groups, :supplier_code
  end
end
