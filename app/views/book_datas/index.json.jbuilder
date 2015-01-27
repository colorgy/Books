json.array!(@book_datas) do |book_data|
  json.extract! book_data, :id, :isbn, :name, :edition, :author, :image_url, :publisher, :price
  json.url book_data_url(book_data, format: :json)
end
