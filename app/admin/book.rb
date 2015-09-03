ActiveAdmin.register Book do

  permit_params :supplier_code, :price, :isbn, :created_at, :updated_at, :deleted_at, :organization_code, :internal_code, :behalf, :buyable, :display_order

  controller do
    def scoped_collection
      super.includes :data
    end
  end

  filter :supplier_code
  filter :price
  filter :isbn
  filter :created_at
  filter :updated_at
  filter :organization_code
  filter :internal_code
  filter :buyable
  filter :behave

  index do
    selectable_column

    column(:id)
    column('Book Name') { |book| a book.data.name, href: admin_book_data_url(book.data) }
    column(:price)
    column(:isbn)
    column(:organization_code)
    column(:buyable)
    column(:behalf)
    column(:supplier_code)
    column(:created_at)
    column(:updated_at)

    actions
  end

  form do |f|
    f.inputs '上書資料' do
      f.input :supplier_code
      f.input :price
      f.input :isbn
      f.input :organization_code
      f.input :internal_code
      f.input :behalf
      f.input :buyable
      f.input :display_order

      f.actions
    end
  end

end
