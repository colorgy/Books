class RenameCoursesBookConfirmedAtToConfirmedAt < ActiveRecord::Migration
  def change
    rename_column :courses, :book_confirmed_at, :confirmed_at
  end
end
