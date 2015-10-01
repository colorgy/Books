ActiveAdmin.register GroupBuyForm do

  permit_params :book_isbn, :course_name, :course_ucode, :mobile, :quantity

  filter :book_isbn

  index do
    selectable_column

    id_column
    column(:book_isbn)
    column(:book_data)
    column(:user)
    column(:user_id)

    column(:course_name)
    column(:mobile)
    column(:quantity)

    column(:created_at)
    column(:updated_at)

    actions
  end
end
