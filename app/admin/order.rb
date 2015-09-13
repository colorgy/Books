ActiveAdmin.register Order do

  permit_params :user_id, :group_code, :book_id, :price, :state, :deleted_at, :created_at, :updated_at, :bill_uuid, :course_ucode, :package_id, :package_course_ucode, :order_date

  scope :all, default: true
  scope :paid
  scope :has_paid
  scope :unpaid

  filter :user_id
  filter :user_name, as: :string
  filter :book_isbn, as: :string
  filter :book_data_name, as: :string
  filter :bill_id
  filter :group_code
  filter :price
  filter :state
  filter :bill_uuid
  filter :course_ucode
  filter :course_name, as: :string
  filter :package_course_ucode
  filter :package_course_name, as: :string
  filter :package_id
  filter :order_date
  filter :deleted_at
  filter :created_at
  filter :updated_at

  controller do
    def scoped_collection
      super.includes :user, :book, :bill, :package
    end
  end

  index do
    item_price_h = Hash[PackageAdditionalItem.all.map{|item| [item.id.to_s, item.price]}]
    item_name_h = Hash[PackageAdditionalItem.all.map{|item| [item.id.to_s, item.name]}]

    selectable_column

    column(:id)
    column(:bill)
    column(:user)
    column(:book)
    column(:price)
    # column(:group_code)
    column(:state) do |order|
      tag = nil
      case order.state
      when "ready"
        tag = :ok
      when "new"
        tag = :warning
      when "payment_pending"
        tag = :warning
      end
      tag.nil? ? status_tag(order.state) : status_tag(order.state, tag)
    end
    column("Course") do |order|
      if order.course.present?
        a order.course_name, href: admin_course_path(order.course)
        span order.course_ucode
      else
        order.course_ucode
      end
    end
    column("additional_items") do |order|
      order.package && order.package.additional_items.reject{|k,v| v != 'on'}.keys.map{|id| item_name_h[id]}
    end
    column(:package)
    column(:package_course) do |order|
      if order.package_course.present?
        a order.package_course_name, href: admin_course_path(order.package_course)
        span order.package_course_ucode
      else
        order.package_course_ucode
      end
    end
    column(:order_date)
    column(:created_at)
    column(:updated_at)

    actions
  end

end
