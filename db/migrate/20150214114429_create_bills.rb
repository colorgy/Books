class CreateBills < ActiveRecord::Migration
  def change
    create_table :bills do |t|
      t.string :uuid, null: false
      t.integer :user_id, null: false
      t.string :type, null: false
      t.float :price, null: false
      t.float :amount, null: false
      t.integer :invoice_id
      t.string :invoice_type, null: false
      t.text :invoice_data
      t.text :data
      t.string :state, null: false
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :bills, :uuid, unique: true
    add_index :bills, :user_id, unique: false
    add_index :bills, :type, unique: false
    add_index :bills, :invoice_id, unique: true
    add_index :bills, :invoice_type, unique: false
    add_index :bills, :state, unique: false
    add_index :bills, :deleted_at, unique: false
  end
end
