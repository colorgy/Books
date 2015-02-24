class AddUpdatedThroughToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :updated_through, :string
  end
end
