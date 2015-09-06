ActiveAdmin.register UserCredit do
  permit_params :user_id, :credits, :name, :book_isbn, :expires_at, :created_at, :updated_at

  filter :user_id
  filter :credits
  filter :name
  filter :book_isbn
  filter :expires_at
  filter :created_at
  filter :updated_at

end
