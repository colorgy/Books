class Course < ActiveRecord::Base
  SIMPLE_SEARCH_LAMBDA = lambda { |query|

    # proceed the queries
    query_id = query.to_i if query == query.to_i.to_s
    queries = query.split(' ')[0..10]
    sql_queries = queries.map { |s| "%#{s}%" }

    # sorting by matches
    sql_sorting = sanitize_sql_array([<<-SQL, sql_queries, sql_queries
      CASE
        WHEN courses.name ILIKE ANY (array[?])
        THEN 0
        WHEN courses.lecturer_name ILIKE ANY (array[?])
        THEN 1
        ELSE 100
      END
    SQL
    ])

    # build the collection
    collection = \
      where(<<-SQL, sql_queries
        (courses.ucode ||
         courses.name ||
         courses.lecturer_name) ILIKE ALL (array[?])
      SQL
      ).order(sql_sorting)

    collection
  }
end
