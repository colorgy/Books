class Book < ActiveRecord::Base
  acts_as_paranoid
  has_paper_trail

  scope :first_with, ->(id) { order(sanitize_sql_array(['CASE WHEN id = ? THEN 0 END', id])) }
  scope :includes_full_data, -> { includes(data: [:courses], supplier: []) }
  scope :simple_search, ->(query, org_code = nil) do
    if org_code.blank? || org_code == 'public'
      org_codes = ['public', '', nil]
    else
      org_codes = [org_code]
    end
    queries = query.split(' ')[0..10]
    sql_queries = queries.map { |s| "%#{s}%" }

    uniq.joins(sanitize_sql_array([<<-SQL, org_codes
      LEFT OUTER JOIN "book_datas" ON "book_datas"."isbn" = "books"."isbn"
      LEFT OUTER JOIN "course_books" ON "course_books"."book_isbn" = "book_datas"."isbn"
      LEFT OUTER JOIN "courses" ON "courses"."ucode" = "course_books"."course_ucode" AND "courses"."organization_code" IN ( ? )
    SQL
    ])).where(<<-SQL, sql_queries, sql_queries
      ("book_datas"."name" || ' ' ||
       "book_datas"."author" || ' ' ||
       "book_datas"."publisher" || ' ' ||
       "courses"."name" || ' ' ||
       "courses"."lecturer_name" || ' ' ||
       "courses"."ucode" || ' ' ||
       "books"."isbn") ILIKE ALL (array[?])
      OR
      ("book_datas"."name" || ' ' ||
       "book_datas"."author" || ' ' ||
       "book_datas"."publisher" || ' ' ||
       "books"."isbn") ILIKE ALL (array[?])
    SQL
    )
  end

  belongs_to :data, class_name: :BookData, foreign_key: :isbn, primary_key: :isbn
  belongs_to :supplier, foreign_key: :supplier_code, primary_key: :code
  has_many :groups

  delegate :name, :author, :isbn, :edition, :image_url,
           :publisher, :original_price, :original_url, :url, :courses,
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
