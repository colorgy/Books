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

    def download_orders orders
      lines = [];

      book_ids = orders.pluck(:book_id);
      books = Book.where(id: book_ids.uniq);
      book_count_h = book_ids.group_by(&:itself);

      lines << %w(書名 本數 isbn supplier);

      books.each do |book|
        book_counts = book_count_h[book.id].size

        lines << [
          book.name,
          book_counts,
          book.isbn,
          book.supplier_code
        ]
      end;

      lines << [];
      lines << [];
      lines << [];

      item_price_h = Hash[PackageAdditionalItem.all.map{|item| [item.id.to_s, item.price]}]
      item_name_h = Hash[PackageAdditionalItem.all.map{|item| [item.id.to_s, item.name]}]

      organizations = Organization.all;

      lines << %w(bill_id order_id sid user_id org user_name receive_name mobile original_price price state isbn 書名 supplier_code pickup course_name lecturer course_ucode pickup_address fee amount price created_at ordered package_course_ucode);
      orders.order(:user_id).each do |order|
        org_code = order.user.organization_code || order.course && order.course.organization_code;
        lines << [
          order.bill.id,
          order.id,
          order.user && order.user.sid,
          order.user_id,
          org_code && organizations.find{|d| d.code == org_code}.short_name,
          order.user && order.user.name,
          order.package && order.package.recipient_name,
          order.package && order.package.recipient_mobile,
          order.book && order.book.data && order.book.data.original_price,
          order.price,
          order.state,
          order.book_isbn,
          order.book && order.book.name,
          order.book.supplier_code,
          order.package.pickup_datetime.strftime('%Y-%-m-%-d'),
          order.course && order.course.name,
          order.course && order.course.lecturer_name,
          order.course_ucode,
          (order.package && order.package.pickup_address == 'caves') ? '敦煌' : order.package && order.package.pickup_address,
          order.bill.processing_fee,
          order.bill.amount,
          order.bill.price,
          order.bill.created_at.strftime('%Y-%-m-%-d'),
          "",
          "",
        ]
      end;

      orders.map(&:package).uniq.each do |package|
        order = package.orders.first;
        org_code = order.user.organization_code || order.course && order.course.organization_code;
        package.additional_items.reject{|k,v| v != 'on'}.keys.each do |addtional_item_id|
          lines << [
            order.bill.id,
            order.id,
            order.user && order.user.sid,
            order.user_id,
            org_code && organizations.find{|d| d.code == org_code}.short_name,
            order.user && order.user.name,
            order.package && order.package.recipient_name,
            order.package && order.package.recipient_mobile,
            item_price_h[addtional_item_id],
            item_price_h[addtional_item_id],
            order.state,
            nil,
            item_name_h[addtional_item_id],
            nil,
            package.pickup_datetime.strftime('%Y-%-m-%-d'),
            # order.course && order.course.name,
            # order.course && order.course.lecturer_name,
            # order.course_ucode,
            (order.package && order.package.pickup_address == 'caves') ? '敦煌' : order.package && order.package.pickup_address,
            order.bill.processing_fee,
            order.bill.amount,
            order.bill.price,
            order.bill.created_at.strftime('%Y-%-m-%-d'),
            "",
            "",
          ]
        end
      end;

      fn = Rails.root.join('tmp', "orders_#{Time.now.strftime('%F %T')}.csv")
      CSV.open(fn, 'w') do |csv|
        lines.each{|l| csv << l}
      end;

      send_file fn
    end
  end


  collection_action :download_packing_list_without_ouya, :method => :get do
    download_orders(Order.order('orders.course_ucode').by_supplier_code.where('orders.created_at > ? AND books.supplier_code != ?', Date.new(2015, 8, 1), 'ouya').where(state: :ready))
  end

  collection_action :download_ouya_packing_list, :method => :get do
    download_orders(Order.by_supplier_code.order('orders.course_ucode').where('orders.created_at > ? AND books.supplier_code = ? AND (orders.state = ? OR orders.state = ?)', Date.new(2015, 8, 1), 'ouya', 'new', 'ready'))
  end

  collection_action :download_packing_list, :method => :get do
    download_orders(Order.order('orders.course_ucode').by_supplier_code.where('orders.created_at > ?', Date.new(2015, 8, 1)).where(state: :ready))
  end

  collection_action :download_cave_base, :method => :get do
    download_orders(Order.order('orders.course_ucode').by_supplier_code.where('orders.created_at > ?', Date.new(2015, 8, 1)).where('state = ?', 'ready').where(order_date: nil))
  end

  action_item only: [:index] do
    link_to "匯出發票", invoice_export_path
  end

  action_item only: :index do
    link_to('出貨表單（沒歐亞）', params.merge(action: :download_packing_list_without_ouya) )
  end

  action_item only: :index do
    link_to('出貨表單（歐亞）', params.merge(action: :download_ouya_packing_list) )
  end

  action_item only: :index do
    link_to('出貨表單（全部）', params.merge(action: :download_packing_list) )
  end

  action_item only: :index do
    link_to('出貨表單（敦煌基底）', params.merge(action: :download_cave_base) )
  end

  index do
    selectable_column

    id_column
    # column(:uuid)
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
    # column(:invoice_type)
    column("Payment Info") { |bill| bill.payment_code || bill.virtual_account }
    # column(:payment_code)
    # column(:virtual_account)
    column(:used_credits)
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
            %w(no book_name supplier_code quantity book_price book_isbn state course_name lecturer package_id course_ucode created_at updated_at).each(&method(:th))
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
            td do
              if book.present?
                a book.name, href: admin_book_path(book)
              else
                book_id
              end
            end
            td { book && book.supplier_code }
            td { quantity }
            td { order.price }
            td do
              if book.present?
                a book.isbn, href: admin_book_data_path(book.data)
              else
                nil
              end
            end
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

    panel(link_to("Package", admin_package_path(bill.orders.first.package))) do
      attributes_table_for bill.orders.first.package do
        row(:recipient_name)
        row(:pickup_address)
        row(:recipient_mobile)
        row(:pickup_datetime)
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
