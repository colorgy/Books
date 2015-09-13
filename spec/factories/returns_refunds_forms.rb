FactoryGirl.define do
  factory :returns_refunds_form do
    if_delivered false
bill_uuid "MyString"
account_bank_code "MyString"
account_number "MyString"
reason "MyText"
image_url "MyString"
status 1
user_id 1
  end

end
