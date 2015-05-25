class RenameColumnAddNameToSupplierStaffs < ActiveRecord::Migration
  def change
    rename_column :supplier_staffs, :provider_code, :supplier_code
    add_column :supplier_staffs, :name, :string
  end
end
