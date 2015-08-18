class AddUpdaterTypeToCourseBooks < ActiveRecord::Migration
  def change
    add_column :course_books, :updater_type, :string
  end
end
