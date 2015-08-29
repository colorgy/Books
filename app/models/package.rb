class Package < ActiveRecord::Base
  include AASM
  has_paper_trail

  SHIPPING_FEE = 80
  RELIEVE_SHIPPING_FEE_IF_ITEMS_MORE_THEN = 2

  scope :is_new, ->  { where(state: 'new') }

  store :additional_items

  belongs_to :user
  has_many :orders

  after_initialize :mark_paid_if_all_paid

  aasm column: :state do
    state :new, initial: true
    state :pending  # the package is pending for delivery
    state :delivering  # the package is marked as shipped by the supplier
    state :delivered  # the package is marked as delivered by the deliverer
    state :received  # the buyer states thet (s)he has received the package
    state :cancelled  # the package canceled, dead state

    event :paid do
      transitions from: :new, to: :pending
      after do
        # the orders may be processing, so mark them (to prevent being refund)
        orders.each(&:ready!)
      end
    end

    event :ship do
      transitions from: :pending, to: :delivering
      after do
        update_attributes(shipped_at: Time.now)
        orders.each do |order|
          order.ship! if order.may_ship?
        end
      end
    end

    event :receive do
      transitions from: :pending, to: :received
      transitions from: :delivering, to: :received
      transitions from: :received, to: :received
      after do
        update_attributes(received_at: Time.now)
        orders.each do |order|
          order.receive! if order.may_receive?
        end
      end
    end
  end

  # Calaulate and update the total amount (addes the shipping fee)
  def calculate_amount
    if orders.size <= RELIEVE_SHIPPING_FEE_IF_ITEMS_MORE_THEN
      self.shipping_fee = SHIPPING_FEE
    end

    self.amount = price + shipping_fee

    additional_items.each_pair do |k, v|
      p = PackageAdditionalItem.find(k.to_i)
      self.amount += p.price
    end
  end

  def additional_items_description
    descriptions = []

    additional_items.each_pair do |k, v|
      p = PackageAdditionalItem.find(k.to_i)
      descriptions << "#{p.name} (NT$ #{p.price})"
    end

    descriptions.join('、')
  end

  def package_additional_items
    items = []

    additional_items.each_pair do |k, v|
      p = PackageAdditionalItem.find(k.to_i)
      items << p
    end

    items
  end

  def bill_deadline
    return pickup_datetime - 5.days if pickup_datetime
    1.week.from_now
  end

  def mark_paid_if_all_paid
    return false if orders.blank? || !persisted?
    self.paid! if may_paid? && !orders.map(&:has_paid?).include?(false)
  end
end
