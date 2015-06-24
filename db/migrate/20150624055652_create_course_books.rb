class CreateCourseBooks < ActiveRecord::Migration
  def change
    create_table :course_books do |t|
      t.string :course_ucode
      t.string :book_isbn
      t.boolean :book_known

      t.string :updated_by
      t.boolean :confirmed

      t.timestamps null: false
    end

    add_index :course_books, :course_ucode
    add_index :course_books, :book_isbn
    add_index :course_books, :book_known
  end
end
