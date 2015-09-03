ActiveAdmin.register Supplier do

  permit_params :name, :code, :created_at, :updated_at, :is_root, :deal_package

  filter :name
  filter :code
  filter :created_at
  filter :updated_at
  filter :is_root
  filter :deal_package

end
