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

end
