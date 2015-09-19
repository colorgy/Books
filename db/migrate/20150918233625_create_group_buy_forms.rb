class CreateGroupBuyForms < ActiveRecord::Migration
  def change
    create_table :group_buy_forms do |t|
      t.integer :user_id
      t.string :book_isbn
      t.string :course_name
      t.string :course_ucode
      t.string :mobile
      t.integer :quantity

      t.timestamps null: false
    end
    add_index :group_buy_forms, :user_id
  end
end
