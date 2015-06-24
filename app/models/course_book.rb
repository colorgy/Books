class CourseBook < ActiveRecord::Base
  belongs_to :course, primary_key: :ucode, foreign_key: :course_ucode
  belongs_to :book_data, primary_key: :isbn, foreign_key: :book_isbn

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :price,
           to: :book_data, prefix: true, allow_nil: true
  delegate :name, :lecturer_name,
           to: :course, prefix: true, allow_nil: true
end
