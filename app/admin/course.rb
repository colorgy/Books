ActiveAdmin.register Course do

  permit_params :organization_code, :department_code, :lecturer_name, :year, :term, :name, :code, :created_at, :updated_at, :general_code, :ucode, :required

  filter :organization_code
  filter :department_code
  filter :lecturer_name
  filter :year
  filter :term
  filter :name
  filter :code
  filter :created_at
  filter :updated_at
  filter :general_code
  filter :ucode
  filter :required

end
