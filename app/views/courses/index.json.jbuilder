json.array!(@courses) do |course|
  json.extract! course, :id, :name, :lecturer_name, :organization_code, :year, :term, :book_isbn, :confirmed_at
end
