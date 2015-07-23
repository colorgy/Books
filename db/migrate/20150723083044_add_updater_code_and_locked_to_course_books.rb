class AddUpdaterCodeAndLockedToCourseBooks < ActiveRecord::Migration
  def change
    add_column :course_books, :updater_code, :string
    add_column :course_books, :locked, :boolean
  end
end
