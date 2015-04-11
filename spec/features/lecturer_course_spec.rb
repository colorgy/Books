require 'rails_helper'

feature "教授上書", :type => :feature do
  include_context "mock Core API"
  before do
    @lecturer_identity = create(:user_identity, identity: "lecturer")
    @lecturer = create(:user, identity: "lecturer", name: @lecturer_identity.name, email: @lecturer_identity.email)
    @lecturer_identity.user = @lecturer
    @lecturer.identities << @lecturer_identity
  end

  scenario "lecturer can create a course with book", :js => true do
    login_as @lecturer
    visit(new_lecturer_course_path(@lecturer_identity))

    # create course and book
    course = build(:course, lecturer_name: @lecturer.name)
    book_datas = create_list(:book_data, 10)

    # fill in course name
    first('#course_name').set(course.name)

    # select use book
    book_data = book_datas.first
    select2_select('.course_book_isbn .select2-choice', book_data.isbn, first: true)

    # fill the rest fields
    first('#course_year').set(course.year)

    within '#course_term' do
      find("option[value=\"#{course.term}\"]").select_option
    end

    first('#course_code').set(course.code)
    first('#course_department_code').set(course.department_code)
    check '#course_required' if course.required
    first('#course_url').set(course.url)

    # submit form and wait for data update
    first("input[type=submit]").click
    sleep 3

    # check saved book data
    saved_course = Course.find_by(lecturer_name: @lecturer.name)
    expect(saved_course.book_data).to eq(book_data)

  end

end
