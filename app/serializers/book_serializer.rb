class BookSerializer < ActiveModel::Serializer
  self.root = false

  attributes :id, :isbn, :name, :edition, :author, :image_url, :publisher, :original_price
end
