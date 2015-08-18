class CreateUserCredits < ActiveRecord::Migration
  def change
    create_table :user_credits do |t|
      t.integer :user_id
      t.integer :credits
      t.string :name
      t.string :book_isbn
      t.datetime :expires_at

      t.timestamps null: false
    end
    add_index :user_credits, :user_id
  end
end
