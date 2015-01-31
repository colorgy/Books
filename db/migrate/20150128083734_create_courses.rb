class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :organization_code, null: false
      t.string :department_code
      t.string :lecturer_name, null: false

      t.integer :year, null: false
      t.integer :term, null: false
      t.string :name, null: false
      t.string :code
      t.string :url
      t.boolean :required, null: false, default: false

      t.string :book_isbn
      t.string :unknown_book_name

      t.datetime :book_confirmed_at

      t.timestamps
    end
  end
end
