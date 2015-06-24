class AddUcodeToCourses < ActiveRecord::Migration
  def change
    add_column :courses, :ucode, :string
    add_index :courses, :ucode
  end
end
