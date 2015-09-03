ActiveAdmin.register Book do

  permit_params :supplier_code, :price, :isbn, :created_at, :updated_at, :deleted_at, :organization_code, :internal_code, :behalf, :buyable, :display_order

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
    column(:price)
    column(:isbn)
    column(:internal_code)
    column(:organization_code)
    column(:buyable)
    column(:behalf)
    column(:display_order)
    column(:supplier_code)
    column(:created_at)
    column(:updated_at)

    actions
  end

end
