class BookData < ActiveRecord::Base
  has_one :book
  has_many :courses, foreign_key: :book_isbn, primary_key: :isbn

  validates :isbn, isbn_format: true, uniqueness: true
  validates :name, presence: true

  def self.search(query)
    book_datas = where("name LIKE ? OR isbn LIKE ? or publisher LIKE ? OR author LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
    if book_datas.empty?
      [new(isbn: "NEW+>#{query}", name: "New: \"#{query}\"")]
    else
      book_datas
    end
  end
end
