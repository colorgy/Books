class ModifyCoursesForV2 < ActiveRecord::Migration
  def change
    add_column :courses, :general_code, :string
    add_index :courses, :general_code
    remove_column :courses, :url
    remove_column :courses, :required
    remove_column :courses, :book_isbn
    remove_column :courses, :unknown_book_name
    remove_column :courses, :confirmed_at
    remove_column :courses, :deleted_at
    remove_column :courses, :version_count
    remove_column :courses, :updated_through
  end
end
