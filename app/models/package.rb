class Package < ActiveRecord::Base
  include AASM
  has_paper_trail

  belongs_to :user
  has_many :orders

  aasm column: :state do
    state :new, initial: true
    state :pending
    state :delivering
    state :delivered
    state :received

    event :paid do
      transitions from: :new, to: :pending
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
    if price < 1000
      self.shipping_fee = 100
    end
    self.amount = price + shipping_fee
  end
end
