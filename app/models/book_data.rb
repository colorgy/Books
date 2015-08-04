class BookData < ActiveRecord::Base
  scope :simple_search, ->(q) { q.downcase!; where('lower(isbn) LIKE ? OR lower(name) LIKE ? OR lower(author) LIKE ? OR lower(publisher) LIKE ?', "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%") }

  has_one :book, foreign_key: :isbn, primary_key: :isbn
  has_many :books, foreign_key: :isbn, primary_key: :isbn
  has_many :course_book, primary_key: :isbn, foreign_key: :book_isbn
  has_many :courses, through: :course_book

  has_attached_file :image, styles: { medium: '1024x1024>', thumb: '300x300#' }
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/

  validates :isbn, uniqueness: true#, isbn_format: true
  validates :name, presence: true

  before_validation :set_image_file_name

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

  def supplier_name
    return nil if book.blank?
    return book.supplier_code if book.supplier.blank?
    book.supplier.name
  end
end
