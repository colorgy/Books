RSpec.shared_context "mock Core API" do
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
end
