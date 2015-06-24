class BookData < ActiveRecord::Base
  has_one :book, foreign_key: :isbn, primary_key: :isbn
  has_many :books, foreign_key: :isbn, primary_key: :isbn

  has_attached_file :image, styles: { medium: '1024x1024>', thumb: '300x300#' }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  validates :isbn, uniqueness: true#, isbn_format: true
  validates :name, presence: true

  before_validation :set_image_file_name

  def self.search(query)
    query.downcase!
    book_datas = where("lower(name) LIKE ? OR isbn LIKE ? or lower(publisher) LIKE ? OR lower(author) LIKE ?", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%").limit(100)
    if book_datas.empty?
      [new(isbn: "NEW+>#{query}", name: "新增: \"#{query}\" (請儘可能詳述書名、作者、版次、出版社)")]
    else
      book_datas
    end
  end

  def set_image_file_name
    return unless image_file_name_changed?
    set_image_file_name_to_uuid
  end

  def set_image_file_name_to_uuid
    self.image_file_name = SecureRandom.uuid + File.extname(image_file_name)
  end

  def image_url
    if image.present?
      image.url
    elsif external_image_url.present?
      external_image_url
    else
      image.url
    end
  end

  def download_external_image
    return if external_image_url.blank?
    self.image = open(external_image_url)
    save
  end
end
