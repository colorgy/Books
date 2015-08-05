class PendingBillCheckWorker
  include Sidekiq::Worker

  def perform
    Bill.payment_pending.find_each do |bill|
      bill.pay_if_paid!
    end
  end
end
