class UserCartItem < ActiveRecord::Base
  scope :with_course, -> { includes(:course) }
  scope :with_book, -> { includes(:book) }
  scope :with_course_and_book, -> { includes(:course, :book) }

  belongs_to :user, counter_cache: :cart_items_count
  belongs_to :book
  belongs_to :course

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :price,
           to: :book, prefix: true, allow_nil: true
  delegate :organization_code, :department_code, :lecturer_name,
           :year, :term, :name, :code, :url, :required, :book_isbn,
           to: :course, prefix: true, allow_nil: true

  validates :quantity, inclusion: 1..12

  def price
    (book.try(:price) || 0) * quantity
  end

  def group_code
    BatchCodeService.generate_group_code(item.course.organization_code, item.course_id, item.book_id)
  end
end
