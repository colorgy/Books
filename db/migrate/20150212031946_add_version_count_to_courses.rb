class AddVersionCountToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :version_count, :integer, null: false, default: 0
  end
end
