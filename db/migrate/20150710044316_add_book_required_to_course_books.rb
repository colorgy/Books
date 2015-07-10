class AddBookRequiredToCourseBooks < ActiveRecord::Migration
  def change
    add_column :course_books, :book_required, :boolean
  end
end
