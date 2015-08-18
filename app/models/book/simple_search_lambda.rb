class Book < ActiveRecord::Base
  SIMPLE_SEARCH_LAMBDA = lambda { |query, org_code = nil|
    # determine the organization code used to filter the courses
    if org_code.blank? || org_code == 'public'
      org_codes = ['public', '', nil]
    else
      org_codes = [org_code]
    end

    # proceed the queries
    query_id = query.to_i if query == query.to_i.to_s
    queries = query.split(' ')[0..10]
    sql_queries = queries.map { |s| "%#{s}%" }

    # sorting by matches
    sql_sorting = sanitize_sql_array([<<-SQL, query_id, sql_queries, sql_queries, sql_queries, sql_queries
      CASE
        WHEN books.id = ?
        THEN 0
        WHEN courses.name ILIKE ANY (array[?])
        THEN 1
        WHEN courses.lecturer_name ILIKE ANY (array[?])
        THEN 1
        WHEN book_datas.name ILIKE ANY (array[?])
        THEN 2
        WHEN book_datas.author ILIKE ANY (array[?])
        THEN 3
        ELSE 100
      END
    SQL
    ])

    # build the collection
    collection = \
      select("DISTINCT ON (books.id, #{sql_sorting}) *, books.id")
      .joins(sanitize_sql_array([<<-SQL, org_codes
        LEFT OUTER JOIN "book_datas" ON "book_datas"."isbn" = "books"."isbn"
        LEFT OUTER JOIN "course_books" ON "course_books"."book_isbn" = "book_datas"."isbn"
        LEFT OUTER JOIN "courses" ON "courses"."ucode" = "course_books"."course_ucode" AND "courses"."organization_code" IN (?)
      SQL
      ])).where(<<-SQL, sql_queries, sql_queries
        (books.id ||
         book_datas.name ||
         book_datas.author ||
         book_datas.publisher ||
         courses.name ||
         courses.lecturer_name ||
         courses.ucode ||
         books.isbn) ILIKE ALL (array[?])
        OR
        (books.id ||
         book_datas.name ||
         book_datas.author ||
         book_datas.publisher ||
         books.isbn) ILIKE ALL (array[?])
      SQL
      ).order(sql_sorting)

    # override the count method to fix SQL error
    collection.send :define_singleton_method, :count, -> { super("DISTINCT (books.id, #{sql_sorting})") }

    collection
  }
end
