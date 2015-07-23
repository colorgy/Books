class TestingBillWorker
  include Sidekiq::Worker

  def perform
    Bill.where(type: 'test_autopay').payment_pending.find_each do |bill|
      bill.pay!
    end
  end
end
