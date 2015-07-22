class CartItemSerializer < ActiveModel::Serializer
  attributes :id, :item_type, :item_price, :quantity

  has_one :group, serializer: GroupSerializer
  has_one :book, serializer: BookSerializer
  has_one :course
end
