ActiveAdmin.register Bill do

  scope :all, default: true
  scope :paid
  scope :payment_pending
  scope :unpaid

  permit_params :uuid, :user_id, :type, :price, :amount, :invoice_id, :invoice_type, :invoice_data, :data, :state, :deleted_at, :created_at, :updated_at, :payment_code, :paid_at, :used_credits, :deadline, :processing_fee, :virtual_account, :used_credit_ids

  filter :id
  filter :uuid
  filter :user_id
  filter :user_name, as: :string
  filter :type
  filter :price
  filter :amount
  filter :invoice_id
  filter :invoice_type
  filter :invoice_data
  filter :data
  filter :state
  filter :deleted_at
  filter :created_at
  filter :updated_at
  filter :payment_code
  filter :paid_at
  filter :used_credits
  filter :deadline
  filter :processing_fee
  filter :virtual_account
  filter :used_credit_ids

  controller do
    def scoped_collection
      super.includes :user
    end
  end

  index do
    selectable_column

    column(:id)
    column(:uuid)
    column(:user)
    column(:price)
    column(:amount)

    column(:state) do |bill|
      tag = nil
      case bill.state
      when "paid"
        tag = :ok
      when "payment_pending"
        tag = :warning
      end
      tag.nil? ? status_tag(bill.state) : status_tag(bill.state, tag)
    end

    column(:type)
    column(:invoice_type)
    column(:payment_code)
    column(:virtual_account)
    column(:processing_fee)
    column(:deadline)
    column(:paid_at)
    column(:created_at)
    column(:updated_at)

    actions
  end

end
