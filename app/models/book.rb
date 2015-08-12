class Book < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  scope :first_with, ->(id) { order(sanitize_sql_array(['CASE WHEN "books"."id" = ? THEN 0 END', id])) }
  scope :includes_full_data, -> { includes(data: [:courses], supplier: []) }
  scope :simple_search, SIMPLE_SEARCH_LAMBDA

  belongs_to :data, class_name: :BookData, foreign_key: :isbn, primary_key: :isbn
  belongs_to :supplier, foreign_key: :supplier_code, primary_key: :code
  has_many :groups

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :original_url, :url, :courses,
           :course_titles_in,
           to: :data, allow_nil: true
  delegate :name, to: :supplier, prefix: true, allow_nil: true

  validates :data, presence: true

  def self.for_org(org_code = 'public')
    org_code = 'public' if org_code.blank?
    where(<<-SQL, org_code, org_code
      books.id IN (
        SELECT DISTINCT ON (books.isbn) books.id FROM books
        WHERE books.organization_code = ?
           OR books.organization_code = ''
           OR books.organization_code = 'public'
           OR books.organization_code IS NULL
        ORDER BY books.isbn, CASE books.organization_code
          WHEN ? THEN 1
          WHEN '' THEN 2
          WHEN NULL THEN 3
          ELSE 4
        END
      )
    SQL
    )
  end

  def delivery_processing_time
    3.days
  end

  def minimum_purchase_quantity
    2
  end

  def free_shipping_purchase_quantity
    5
  end

  def shipping_fee
    300
  end
end
