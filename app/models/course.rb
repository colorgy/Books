class Course < ActiveRecord::Base
  belongs_to :book_data,
              class_name: :BookData, foreign_key: :book_isbn, primary_key: :isbn

  scope :confirmed, -> { where(confirmed: true) }
end
