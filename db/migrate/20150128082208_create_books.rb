class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :provider
      t.float :price, null: false
      t.string :book_data_isbn

      t.timestamps
    end

    add_index :books, :book_data_isbn, unique: true
  end
end
