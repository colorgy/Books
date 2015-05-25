class RenameProviderToSupplier < ActiveRecord::Migration
  def change
    rename_column :book_datas, :known_provider, :known_supplier
    rename_column :books, :provider, :supplier_code
    rename_table :providers, :supplier_staffs
  end
end
