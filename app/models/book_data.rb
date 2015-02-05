class BookData < ActiveRecord::Base
  has_one :book, foreign_key: :book_data_isbn, primary_key: :isbn
  has_many :courses, foreign_key: :book_isbn, primary_key: :isbn

  validates :isbn, uniqueness: true#, isbn_format: true
  validates :name, presence: true

  def self.search(query)
    book_datas = where("name LIKE ? OR isbn LIKE ? or publisher LIKE ? OR author LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
    if book_datas.empty?
      [new(isbn: "NEW+>#{query}", name: "新增: \"#{query}\" (請儘可能詳述書名、作者、版次、出版社)")]
    else
      book_datas
    end
  end
end
