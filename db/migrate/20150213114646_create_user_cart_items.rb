class CreateUserCartItems < ActiveRecord::Migration
  def change
    create_table :user_cart_items do |t|
      t.integer :user_id
      t.integer :book_id
      t.integer :course_id

      t.timestamps
    end

    add_index :user_cart_items, :user_id, unique: false
    add_index :user_cart_items, :book_id, unique: false
    add_index :user_cart_items, :course_id, unique: false
  end
end
