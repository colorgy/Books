ActiveAdmin.register Order do

  permit_params :user_id, :group_code, :book_id, :price, :state, :deleted_at, :created_at, :updated_at, :bill_uuid, :course_ucode, :package_id

  scope :all, default: true
  scope :paid
  scope :has_paid
  scope :unpaid

  filter :user_id
  filter :bill_id
  filter :group_code
  filter :price
  filter :state
  filter :bill_uuid
  filter :course_ucode
  filter :package
  filter :deleted_at
  filter :created_at
  filter :updated_at

  controller do
    def scoped_collection
      super.includes :user, :book, :bill
    end
  end

  index do
    selectable_column

    column(:user)
    column(:book)
    column(:price)
    column(:group_code)
    column(:state) do |order|
      tag = nil
      case order.state
      when "paid"
        tag = :ok
      when "new"
        tag = :warning
      when "payment_pending"
        tag = :warning
      end
      tag.nil? ? status_tag(order.state) : status_tag(order.state, tag)
    end
    column(:bill)
    column(:course_ucode)
    column(:package_id)
    column(:created_at)
    column(:updated_at)

    actions
  end

end
