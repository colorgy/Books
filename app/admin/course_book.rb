ActiveAdmin.register CourseBook do

  permit_params :course_ucode, :book_isbn, :book_known, :updated_by, :confirmed, :created_at, :updated_at, :book_required, :updater_code, :locked, :updater_type

  filter :course_ucode
  filter :book_isbn
  filter :book_known
  filter :updated_by
  filter :confirmed
  filter :created_at
  filter :updated_at
  filter :book_required
  filter :updater_code
  filter :locked
  filter :updater_type

  form do |f|
    f.inputs '關聯資料' do

      f.input :course_ucode
      f.input :book_isbn
      f.input :book_known
      f.input :updated_by
      f.input :confirmed
      f.input :book_required
      f.input :updater_code
      f.input :locked
      f.input :updater_type

      f.actions
    end
  end

end
