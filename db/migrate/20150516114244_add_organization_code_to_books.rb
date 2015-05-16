class AddOrganizationCodeToBooks < ActiveRecord::Migration
  def change
    add_column :books, :organization_code, :string
    add_index :books, :organization_code
  end
end
