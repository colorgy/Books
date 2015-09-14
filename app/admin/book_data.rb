ActiveAdmin.register BookData do

  permit_params :isbn, :name, :edition, :author, :external_image_url, :url, :publisher, :original_url, :original_price, :known_supplier, :created_at, :updated_at, :temporary_book_name, :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :internal_code

  filter :isbn
  filter :name
  filter :author
  filter :url
  filter :publisher
  filter :original_url
  filter :original_price
  filter :known_supplier
  filter :internal_code
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    column(:id)
    column(:isbn)
    column(:known_supplier)
    column(:original_price)
    column(:name)
    column(:edition)
    column(:author)
    column(:publisher)
    column(:created_at)
    column(:updated_at)

    actions
  end

  index as: :detailed_table do |book_data|
    selectable_column
    column(:id)

    column(:isbn)
    column(:name)
    column(:edition)
    column(:author)
    column(:external_image_url)
    column(:url)
    column(:publisher)
    column(:original_url)
    column(:original_price)
    column(:known_supplier)
    column(:created_at)
    column(:updated_at)
    column(:temporary_book_name)
    column(:image_file_name)
    column(:image_content_type)
    column(:image_file_size)
    column(:image_updated_at)
    column(:internal_code)

    actions
  end

end
