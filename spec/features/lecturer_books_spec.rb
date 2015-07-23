require 'rails_helper'

feature "The lecturer-books registration", :type => :feature, :retry => 10 do
  before do
    # ActiveResource::HttpMock.respond_to do |mock|
    #   mock.post   "/people.json",   {}, @matz, 201, "Location" => "/people/1.json"
    #   mock.get    "/people/1.json", {}, @matz
    # end
    stub_request(:get, 'https://colorgy.io//api/v1/organizations.json?fields%5Bdepartment%5D=code,name,short_name,group,departments')
      .to_return(status: 200, :body => <<-EOR
          [
            {
              "code": "NTHU",
              "name": "國立清華大學",
              "short_name": "清大",
              "id": "NTHU",
              "_type": "organization"
            },
            {
              "code": "NTU",
              "name": "國立臺灣大學",
              "short_name": "台大",
              "id": "NTU",
              "_type": "organization"
            },
            {
              "code": "NTUST",
              "name": "國立臺灣科技大學",
              "short_name": "台科大",
              "id": "NTUST",
              "_type": "organization"
            }
          ]
        EOR
      )

    create_list(:book_data, 10)
    create_list(:course, 5,  :current, organization_code: 'NTUST', lecturer_name: 'Lecturer One')
    @courses = Course.current.where(lecturer_name: 'Lecturer One')

    # Courses with historical book data
    @historical_course_1 = create(:course, year: @courses.first.year - 1,
                                           organization_code: @courses.first.organization_code,
                                           department_code: @courses.first.department_code,
                                           lecturer_name: @courses.first.lecturer_name,
                                           term: @courses.first.term,
                                           name: @courses.first.name,
                                           general_code: @courses.first.general_code)

    @historical_course_1.course_book.create!(book_data: BookData.last)
    @historical_course_2 = create(:course, year: @courses.second.year - 1,
                                           organization_code: @courses.second.organization_code,
                                           department_code: @courses.second.department_code,
                                           lecturer_name: @courses.second.lecturer_name,
                                           term: @courses.second.term,
                                           name: @courses.second.name,
                                           general_code: @courses.second.general_code)

    @historical_course_2.course_book.create!(book_data: BookData.last)

    # Courses that already has book data
    @courses.third.course_book.create!(book_data: BookData.last)
    @courses.fourth.course_book.create!(book_data: BookData.last)
  end

  scenario "User registers books", js: true do
    page.driver.try :block_unknown_urls
    visit(lecturer_books_path)
    expect(page).to have_content('歡迎使用')
    execute_script("React.addons.TestUtils.Simulate.change($('.Select-input input')[0], { target: { value: 'NTUST' } })")
    execute_script("React.addons.TestUtils.Simulate.change($('.Select-input input')[0], { target: { value: 'NTUST' } })")
    execute_script("React.addons.TestUtils.Simulate.change($('.Select-input input')[0], { target: { value: 'NTUST' } })")
    execute_script("React.addons.TestUtils.Simulate.change($('.Select-input input')[0], { target: { value: 'NTUST' } })")
    execute_script("React.addons.TestUtils.Simulate.change($('.Select-input input')[0], { target: { value: 'NTUST' } })")
    sleep 1
    expect(page).to have_content('科技大學')
    execute_script("React.addons.TestUtils.Simulate.click($('.Select-option')[0])")

    execute_script("React.addons.TestUtils.Simulate.change($('.Select-input input')[0], { target: { value: 'Lecturer One' } })")
    sleep 1
    expect(page).to have_content('Lecturer One')
    execute_script("React.addons.TestUtils.Simulate.click($('.Select-option')[0])")

    # First Course - with historical book data
    # ask if the old book will be continued used
    expect(page).to have_content('是')
    expect(@courses.first.course_book).to be_blank
    execute_script("React.addons.TestUtils.Simulate.click($('.btn--success')[0])")
    sleep 1
    @courses.first.reload
    expect(@courses.first.course_book).not_to be_blank
    expect(@courses.first.course_book.first.book_isbn).to eq(@historical_course_1.course_book.first.book_isbn)

    # Second Course - with historical book data
    # ask if the old book will be continued used
    expect(page).to have_content('是')
    expect(@courses.second.course_book).to be_blank
    # reject it
    execute_script("React.addons.TestUtils.Simulate.click($('.btn--danger')[0])")
    sleep 1
    @courses.second.reload
    # this will create a blank course_book
    expect(@courses.second.course_book).not_to be_blank
    expect(@courses.second.course_book.first.book_isbn).to be_blank
    # then select a new book in the next step
    execute_script("React.addons.TestUtils.Simulate.change($('.search-select input')[0], { target: { value: '#{BookData.second.name}' } })")
    expect(page).to have_content(BookData.second.isbn)
    execute_script("React.addons.TestUtils.Simulate.click($('.search-select-selections div')[0])")
    expect(page).to have_content("是")
    expect(page).to have_content("#{BookData.second.name}")
    # the data should be written into DB
    @courses.second.reload
    expect(@courses.second.course_book.first.book_isbn).to eq(BookData.second.isbn)
    # click confirm to continue
    execute_script("React.addons.TestUtils.Simulate.click($('.btn')[0])")

    # Third Course - already have book data
    expect(page).to have_content('是')
    execute_script("React.addons.TestUtils.Simulate.click($('.btn--success')[0])")

    # Fourth Course - already have book data
    expect(page).to have_content('是')
    # reject it
    execute_script("React.addons.TestUtils.Simulate.click($('.btn--danger')[0])")
    sleep 1
    @courses.fourth.reload
    # this will create a blank course_book
    expect(@courses.fourth.course_book).not_to be_blank
    expect(@courses.fourth.course_book.first.book_isbn).to be_blank
    # then select a new book in the next step
    execute_script("React.addons.TestUtils.Simulate.change($('.search-select input')[0], { target: { value: '#{BookData.second.name}' } })")
    expect(page).to have_content(BookData.second.isbn)
    sleep(1)
    execute_script("React.addons.TestUtils.Simulate.click($('.search-select-selections div')[1])")
    expect(page).to have_content("是")
    expect(page).to have_content("#{BookData.second.name}")
    # the data should be written into DB
    @courses.fourth.reload
    expect(@courses.fourth.course_book.first.book_isbn).to eq(BookData.second.isbn)
    # click confirm to continue
    execute_script("React.addons.TestUtils.Simulate.click($('.btn')[0])")

    # Fifth Course - no book data
    execute_script("React.addons.TestUtils.Simulate.change($('.search-select input')[0], { target: { value: '#{BookData.third.isbn}' } })")
    expect(page).to have_content(BookData.third.name)
    execute_script("React.addons.TestUtils.Simulate.click($('.search-select-selections div')[0])")
    expect(page).to have_content("是")
    expect(page).to have_content("#{BookData.second.name}")
    # the data should be written into DB
    @courses.fifth.reload
    expect(@courses.fifth.course_book.first.book_isbn).to eq(BookData.third.isbn)
    # click confirm to continue
    execute_script("React.addons.TestUtils.Simulate.click($('.btn')[0])")

    # Ask if suggest buy book
    expect(page).to have_content('好')
    execute_script("React.addons.TestUtils.Simulate.click($('.btn')[0])")

    # Done, can leave suggestions
    expect(page).to have_content('完成')
    execute_script("React.addons.TestUtils.Simulate.change($('textarea')[0], { target: { value: 'Great!' } })")
    execute_script("React.addons.TestUtils.Simulate.click($('.btn')[0])")

    sleep 1

    # Check if the course_books are marked as book_required
    @courses.each do |course|
      course.reload
      expect(course.course_book.first.book_required).to be true
    end

    # Check the feedback
    feedback = Feedback.last

    expect(feedback.content).to eq('Great!')
    expect(feedback.sent_at).to eq('lecturer-books')
  end
end
