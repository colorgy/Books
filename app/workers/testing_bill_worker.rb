class TestingBillWorker
  include Sidekiq::Worker

  def perform
    Bill.unpaid.where(type: 'test_autopay').find_each do |bill|
      bill.pay!
    end
  end
end
