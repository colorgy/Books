json.array!(@books) do |book|
  json.extract! book, :id, :isbn, :name, :edition, :author, :image_url, :url, :publisher, :original_url, :original_price, :supplier_name, :created_at, :updated_at, :courses, :price
end

