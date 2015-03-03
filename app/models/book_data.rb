class BookData < ActiveRecord::Base
  has_one :book, foreign_key: :isbn, primary_key: :isbn
  has_many :books, foreign_key: :isbn, primary_key: :isbn
  has_many :courses, foreign_key: :book_isbn, primary_key: :isbn

  validates :isbn, uniqueness: true#, isbn_format: true
  validates :name, presence: true

  def self.search(query)
    query.downcase!
    book_datas = where("lower(name) LIKE ? OR isbn LIKE ? or lower(publisher) LIKE ? OR lower(author) LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%").limit(100)
    if book_datas.empty?
      [new(isbn: "NEW+>#{query}", name: "新增: \"#{query}\" (請儘可能詳述書名、作者、版次、出版社)")]
    else
      book_datas
    end
  end
end
