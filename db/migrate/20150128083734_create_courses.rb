class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.integer :year
      t.integer :term
      t.string :name
      t.text :description
      t.integer :credits
      t.string :url

      t.string :book_isbn
      t.integer :user_id
      t.integer :organization_id
      t.integer :lecturer_id

      t.datetime :confirmed_at

      t.timestamps
    end

  end
end
