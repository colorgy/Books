class RenameBooksBookDataIsbnToIsbn < ActiveRecord::Migration
  def up
    remove_index :books, :book_data_isbn
    rename_column :books, :book_data_isbn, :isbn
    add_index :books, :isbn, unique: false
  end

  def down
    remove_index :books, :isbn
    rename_column :books, :isbn, :book_data_isbn
    add_index :books, :book_data_isbn, unique: true
  end
end
