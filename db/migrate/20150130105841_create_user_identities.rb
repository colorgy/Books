class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.integer :user_id
      t.string :organization_code
      t.string :department_code
      t.string :uid
      t.string :email
      t.string :identity

      t.timestamps
    end
  end
end
