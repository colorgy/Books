class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :user_id, null: false
      t.string :batch, null: false
      t.string :organization_code, null: false
      t.string :group, null: false
      t.integer :book_id, null: false
      t.integer :course_id, null: false
      t.float :price
      t.integer :bill_id, null: true
      t.string :state, null: false
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :orders, :user_id, unique: false
    add_index :orders, :batch, unique: false
    add_index :orders, :organization_code, unique: false
    add_index :orders, :group, unique: false
    add_index :orders, :book_id, unique: false
    add_index :orders, :course_id, unique: false
    add_index :orders, :bill_id, unique: false
    add_index :orders, :state, unique: false
    add_index :orders, :deleted_at, unique: false
  end
end
