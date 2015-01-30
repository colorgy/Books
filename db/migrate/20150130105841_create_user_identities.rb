class CreateUserIdentities < ActiveRecord::Migration
  def change
    create_table :user_identities do |t|
      t.integer :user_id, null: false
      t.string :organization_code, null: false
      t.string :department_code
      t.string :uid
      t.string :name
      t.string :email
      t.string :identity, null: false

      t.timestamps
    end
  end
end
