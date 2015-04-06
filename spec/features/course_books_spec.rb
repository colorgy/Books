require 'rails_helper'

feature "人人書單", :type => :feature do
  before do
    org_json = <<-END
    [
      {
        "code": "NTUST",
        "name": "國立臺灣科技大學",
        "short_name": "台科大",
        "id": "NTUST",
        "_type": "organization"
      },
      {
        "code": "NTU",
        "name": "國立臺灣大學",
        "short_name": "台大",
        "id": "NTU",
        "_type": "organization"
      }
    ]
    END
    stub_request(:get, "http://colorgy.dev/api/v1/organizations.json?fields%5Bdepartment%5D=code,name,short_name,group,departments").to_return(body: org_json)

    page.driver.try(:block_unknown_urls)
  end

  scenario "anyone can update book data for existing non-locked course", :js => true do
    # create some course and books
    courses = create_list(:course, 10, organization_code: 'NTUST')
    book_datas = create_list(:book_data, 10)

    # user visits the course_book page
    visit(course_books_path)

    # step 1 - select the school
    select2_select('.step-1 .select2-choice', '台科大')

    # step 2 - select the lecturer
    course = courses.first
    lecturer_name = course.lecturer_name
    select2_select('.step-2 .select2-choice', lecturer_name)

    # step 3 - choose a book of a course by book name
    book_data = book_datas.first
    select2_select('.step-3 .select2-choice', book_data.name, first: true)
    # do NOT test the results of book searching here - it should be done in an independent API request spec

    # check the results
    sleep 1
    course.reload
    expect(course.book_data).to eq(book_data)
  end
end
