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

  action_item only: [:index] do
    link_to "匯出發票", invoice_export_path
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

  show do
    panel "Orders" do
      table do
        thead do
          tr do
            %w(no book_name quantity book_price book_isbn state course_name lecturer course_ucode created_at updated_at).each(&method(:th))
          end
        end

        orders = bill.orders
        orders.pluck(:book_id).group_by(&:itself).each_with_index do |(book_id, id_arr), index|
          quantity = id_arr.size
          order = orders.find_by(book_id: book_id)
          book = Book.find(book_id)
          course = order.course

          tr do
            td { index+1 }
            td { a book.name, href: admin_book_path(book) }
            td { quantity }
            td { order.price }
            td { a book.isbn, href: admin_book_data_path(book.data) }
            td { order.state }
            td { a course.name, href: admin_course_path(course) }
            td { a course.lecturer_name, href: admin_course_path(course) }
            td { a order.course_ucode, href: admin_course_path(course) }
            td { order.created_at }
            td { order.updated_at }
          end
        end
      end
    end

  end

  sidebar "Bill Info", only: :show do
    attributes_table_for bill do
      row(:uuid)
      row(:user_id)
      row(:user_fbid) { |bill| a bill.user.fbid, href: "https://www.facebook.com/#{bill.user.fbid}" }
      row(:type)
      row(:price)
      row(:amount)
      row(:invoice_id)
      row(:invoice_type)
      row(:invoice_data)
      row(:data)
      row(:state)
      row(:deleted_at)
      row(:created_at)
      row(:updated_at)
      row(:payment_code)
      row(:paid_at)
      row(:used_credits)
      row(:deadline)
      row(:processing_fee)
      row(:virtual_account)
      row(:used_credit_ids)
    end
  end

end
