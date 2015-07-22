class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.integer :user_id, null: false
      t.string :recipient_name, null: false
      t.string :pickup_address, null: false
      t.string :recipient_mobile, null: false
      t.datetime :pickup_datetime, null: false
      t.integer :orders_count, null: false, default: 0
      t.string :state, null: false
      t.integer :price, null: false
      t.integer :amount, null: false
      t.integer :shipping_fee, null: false, default: 0
      t.datetime :shipped_at
      t.datetime :received_at

      t.timestamps null: false
    end
    add_index :packages, :user_id
    add_index :packages, :state
  end
end
