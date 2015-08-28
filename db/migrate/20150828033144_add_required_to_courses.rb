class AddRequiredToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :required, :boolean
  end
end
