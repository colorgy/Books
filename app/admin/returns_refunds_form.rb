# if_delivered
# bill_uuid
# account_bank_code
# account_number
# reason
# status
# user_id
# created_at
# updated_at
# condition
# image_url_file_name
# image_url_content_type
# image_url_file_size
# image_url_updated_at
# phone_number

ActiveAdmin.register ReturnsRefundsForm do
  menu label: "退貨要求"

  permit_params :if_delivered, :bill_uuid, :account_bank_code, :account_number, :reason, :status, :user_id, :created_at, :updated_at, :condition, :image_url_file_name, :image_url_content_type, :image_url_file_size, :image_url_updated_at, :phone_number

  filter :if_delivered
  filter :user_id
  filter :user_name, as: :string
  filter :user_fbid, as: :string
  filter :bill_uuid
  filter :account_bank_code
  filter :account_number
  filter :reason
  filter :status
  filter :condition
  filter :image_url_file_name
  filter :phone_number
  filter :created_at
  filter :updated_at

  controller do
    def scoped_collection
      super.includes :user
    end
  end

  index do
    selectable_column

    column(:if_delivered)
    column(:user)
    column("FB") do |rfform|
      a rfform.user.fbid, href: "https://facebook.com/#{rfform.user.fbid}"
    end
    column("Bill") do |rfform|
      bill = Bill.find_by(uuid: rfform.bill_uuid)
      if bill.nil?
        rfform.bill_uuid
      else
        link_to rfform.bill_uuid, admin_bill_path(bill)
      end
    end
    column(:account_bank_code)
    column(:account_number)
    column(:reason)
    column(:status)
    column(:condition)
    column(:image_url_file_name)
    column(:phone_number)
    column(:created_at)
    column(:updated_at)

    actions
  end
end
