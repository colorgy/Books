ActiveAdmin.register Book do

  permit_params :supplier_code, :price, :isbn, :created_at, :updated_at, :deleted_at, :organization_code, :internal_code, :behalf, :buyable, :display_order, :out_of_stock, :post_serial_no

  controller do
    def scoped_collection
      super.includes :data
    end
  end

  filter :id
  filter :isbn
  filter :post_serial_no
  filter :data_name,  as: :string
  filter :data_author,  as: :string
  filter :data_known_supplier,  as: :string
  filter :data_publisher, as: :string
  filter :price
  filter :supplier_code
  filter :created_at
  filter :updated_at
  filter :organization_code
  filter :internal_code
  filter :buyable
  filter :behave
  filter :out_of_stock

  index do
    selectable_column

    id_column
    column(:post_serial_no)
    column('Book Name') do |book|
      if book.data.present?
        a book.data.name, href: admin_book_data_url(book.data)
      else
        book.isbn
      end
    end
    column('Author') { |book| book.data.author }
    column('Publisher') { |book| book.data.publisher }
    column(:price)
    column(:isbn)
    column(:organization_code)
    column(:buyable)
    column(:behalf)
    column(:out_of_stock)
    column(:supplier_code)
    column(:created_at)
    column(:updated_at)

    actions
  end

  form do |f|
    f.inputs '上書資料' do
      f.input :supplier_code
      f.input :post_serial_no
      f.input :price
      f.input :isbn
      f.input :organization_code
      f.input :internal_code
      f.input :behalf
      f.input :buyable
      f.input :out_of_stock
      f.input :display_order

      f.actions
    end
  end

end
