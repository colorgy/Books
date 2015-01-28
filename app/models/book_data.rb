class BookData < ActiveRecord::Base
  has_one :book
  has_many :courses, foreign_key: :book_isbn, primary_key: :isbn

  validates :isbn, isbn_format: true, uniqueness: true
end
