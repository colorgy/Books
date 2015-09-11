class AddCourseRequiredToBook < ActiveRecord::Migration
  def change
    add_column :books, :course_required, :boolean, null: false, default: true
  end
end
