class AddSidToUserIdentities < ActiveRecord::Migration
  def change
    add_column :user_identities, :sid, :integer
    add_column :user_identities, :organization_name, :string
    add_column :user_identities, :department_name, :string

    add_index :user_identities, :sid, unique: true
  end
end
