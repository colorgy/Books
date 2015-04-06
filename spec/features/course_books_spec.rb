require 'rails_helper'

feature "Course Books", :type => :feature do
  scenario "Anyone can update books data for existing course", :js => true do
    # mock datas
    org_json = <<-END
    [
      {
        "code":"NTUST",
        "name":"國立臺灣科技大學",
        "short_name":"台科大",
        "id":"NTUST",
        "_type":"organization"
      }
    ]
    END
    stub_request(:get, "http://colorgy.dev//api/v1/organizations.json?fields%5Bdepartment%5D=code,name,short_name,group,departments").with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => org_json, :headers => {})

    courses = create_list(:course, 10, organization_code: 'NTUST')
    lecturer_name = courses[0].lecturer_name

    page.visit course_books_path

    # select organization
    # within 'select' do
    # find('#org-select option[value=NTUST]').select_option
    puts page.all("#org-select")
    # end

    page.execute_script("i = $('#lecturer-select input').first();
                    i.val('#{courses.first.lecturer_name}').trigger('keyup');");

    abc =  page.all("#org-select")
    binding.pry
    # select2('國立臺灣科技大學 (台科大)', from: '#s2id_org-select')
    # ntust_org_option = all('#org-select option').first

    # create courses

    # ntust_org_option.select_option
    # click_on 's2id_lecturer-select'

    puts "helloworld"
  end

end
