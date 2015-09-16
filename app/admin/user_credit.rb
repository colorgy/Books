ActiveAdmin.register UserCredit do
  permit_params :user_id, :credits, :name, :book_isbn, :expires_at, :created_at, :updated_at

  filter :user_id
  filter :credits
  filter :name
  filter :book_isbn
  filter :expires_at
  filter :created_at
  filter :updated_at

  index do
    selectable_column

    id_column
    column(:user)
    column(:credits)
    column(:name)
    column(:book_isbn)
    column(:expires_at)
    column(:created_at)
    column(:updated_at)

    actions
  end


  show do
    attributes_table do
      row(:user_id)
      row(:credits)
      row(:name)
      row(:book_isbn)
      row(:expires_at)
      row(:created_at)
      row(:updated_at)
    end
  end


  form do |f|
    f.inputs do

      f.input :user_id
      f.input :credits
      f.input :name
      f.input :book_isbn
      f.input :expires_at
      f.input :created_at
      f.input :updated_at

      f.actions
    end
  end

end
