class TasksController < ApplicationController
  before_action :check_api_key

  def payment_code_check
    unpaid_bills = Bill.where(type: 'payment_code', state: 'payment_pending')

    paid_count = 0
    unpaid_bills.find_each do |bill|
      if NewebPayService.reget_payment_code(bill.uuid, bill.amount) == true
        bill.pay!
        paid_count += 1
      end
    end

    render(json: { success: 200, paid_count: paid_count }, status: 200)
  end

  private

  def check_api_key
    render(json: { error: 403, message: 'Bad token.' }, status: 403) and return if params[:token] != ENV['TASK_API_KEY']
  end
end
