class AddCourseUcodeToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :course_ucode, :string
    add_index :groups, :course_ucode
  end
end
