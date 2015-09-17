ActiveAdmin.register Package do


  permit_params :user_id, :recipient_name, :pickup_address, :recipient_mobile, :pickup_datetime, :orders_count, :state, :price, :amount, :shipping_fee, :shipped_at, :received_at, :created_at, :updated_at, :additional_items

  filter :user_id
  filter :user_name, as: :string
  filter :recipient_name
  filter :pickup_address
  filter :recipient_mobile
  filter :pickup_datetime
  filter :orders_count
  filter :state
  filter :price
  filter :amount
  filter :shipping_fee
  filter :shipped_at
  filter :received_at
  filter :created_at
  filter :updated_at
  filter :additional_items

  index do
    selectable_column

    id_column
    column(:user)
    column(:recipient_name)
    column(:pickup_address)
    column(:recipient_mobile)
    column(:pickup_datetime)
    column(:orders_count)

    column(:state) do |package|
      tag = nil
      case package.state
      when "received"
        tag = :ok
      when "delivered"
        tag = :ok
      when "delivering"
        tag = :warning
      when "pending"
        tag = :warning
      when "new"
        tag = :warning
      end
      tag.nil? ? status_tag(package.state) : status_tag(package.state, tag)
    end

    column(:price)
    column(:amount)
    column(:additional_items)
    column(:shipping_fee)
    column(:shipped_at)
    column(:received_at)
    column(:created_at)
    column(:updated_at)

    actions
  end

  form do |f|
    f.inputs '包裹資料' do
      f.input :user_id
      f.input :recipient_name
      f.input :pickup_address
      f.input :recipient_mobile
      f.input :pickup_datetime
      f.input :orders_count
      f.input :state
      f.input :price
      f.input :amount
      f.input :shipping_fee
      f.input :shipped_at
      f.input :received_at
      f.input :created_at
      f.input :updated_at
      # f.input :additional_items

      f.actions
    end
  end

end
