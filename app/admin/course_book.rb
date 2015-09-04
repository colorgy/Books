ActiveAdmin.register CourseBook do

  permit_params :course_ucode, :book_isbn, :book_known, :updated_by, :confirmed, :created_at, :updated_at, :book_required, :updater_code, :locked, :updater_type

  controller do
    def scoped_collection
      super.includes :course, :book_data
    end
  end

  filter :course_ucode
  filter :course_name, as: :string
  filter :course_lecturer_name, as: :string
  filter :course_year, as: :numeric
  filter :course_term, as: :numeric
  filter :book_isbn
  filter :book_data_name, as: :string
  filter :book_known
  filter :confirmed
  filter :book_required
  filter :updater_code
  filter :created_at
  filter :updated_at

  index do
    selectable_column

    column('Course Ucode') {|cb| cb.course.present? ? a(cb.course_ucode, href: admin_course_path(cb.course)) : cb.course_ucode }
    column('Course Name', sortable: true)  {|cb| cb.course.present? ? a(cb.course.name, href: admin_course_path(cb.course)) : cb.course_ucode }
    column('Book Isbn') {|cb| cb.book_data.present? ? a(cb.book_isbn, href: admin_book_data_path(cb.book_data)) : cb.book_isbn }
    column('Book Name', sortable: true) {|cb| cb.book_data.present? ? a(cb.book_data.name, href: admin_book_data_path(cb.book_data)) : cb.book_isbn }
    column(:updater_code)
    column(:book_required)
    column(:book_known)
    column(:locked)
    column(:confirmed)

    actions
  end

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
