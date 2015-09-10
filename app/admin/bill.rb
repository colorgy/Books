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

      total_price = 0
      calculate_strings = []

      table do
        thead do
          tr do
            %w(no book_name quantity book_price book_isbn state course_name lecturer package_id course_ucode created_at updated_at).each(&method(:th))
          end
        end


        orders = bill.orders
        orders.pluck(:book_id).group_by(&:itself).each_with_index do |(book_id, id_arr), index|
          quantity = id_arr.size
          order = orders.find_by(book_id: book_id)
          book = Book.find(book_id)
          course = order.course

          total_price += quantity * order.price
          calculate_strings << "#{order.price} * #{quantity}"

          tr do
            td { index+1 }
            td { a book.name, href: admin_book_path(book) }
            td { quantity }
            td { order.price }
            td { a book.isbn, href: admin_book_data_path(book.data) }
            td { order.state }
            td {
              if course.present?
                a course.name, href: admin_course_path(course)
              else
                order.course_ucode
              end
            }
            td {
              if course.present?
                a course.lecturer_name, href: admin_course_path(course)
              else
                order.course_ucode
              end
            }
            td { a order.package_id, href: admin_package_path(order.package_id) }
            td {
              if course.present?
                a order.course_ucode, href: admin_course_path(course)
              else
                order.course_ucode
              end
            }
            td { order.created_at }
            td { order.updated_at }
          end
        end

      end
      span do
        "小計： #{calculate_strings.join(' + ')} = #{total_price}"
      end
    end

    panel "Addtional Items" do
      total_price = 0
      calculate_strings = []

      table do
        thead do
          tr do
            %w(no name price).each(&method(:th))
          end
        end


        item_price_h = Hash[PackageAdditionalItem.all.map{|item| [item.id.to_s, item.price]}]
        item_name_h = Hash[PackageAdditionalItem.all.map{|item| [item.id.to_s, item.name]}]

        bill.orders.map(&:package).uniq.each do |package|
          package.additional_items.reject{|k,v| v != 'on'}.keys.each_with_index do |addtional_item_id, item_index|

            item_price = item_price_h[addtional_item_id]
            total_price += item_price
            calculate_strings << item_price

            tr do
              td item_index+1
              td item_name_h[addtional_item_id]
              td item_price_h[addtional_item_id]
            end
          end
        end
      end

      span do
        "小計： #{calculate_strings.join(' + ')} = #{total_price}"
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
