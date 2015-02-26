class AddOrganizationCodeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :organization_code, :string
    add_index :groups, :organization_code, unique: false
  end
end
