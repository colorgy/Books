json.array!(@courses) do |course|
  json.extract! course, :id, :ucode, :code, :name, :lecturer_name, :organization_code, :year, :term, :course_books
end
