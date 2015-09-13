class OrdersController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = current_user.bills.order(created_at: :desc).page(params[:page])
  end

  def create
    @cart_items = current_user.cart_items.includes_default

    if params[:confirmed]
      # really checkout
      @data = current_user.checkout!(bill_params, package_attrs: package_params)
      if @data[:bill].id.present?
        if @data[:bill].type == 'credit_card'
          redirect_to credit_card_pay_redirect_path(@data[:bill]) and return
        else
          redirect_to @data[:bill] and return
        end
      end
    # elsif @cart_items.blank?
    #   redirect_to root_path and return
    else
      # let the user confirm their order
      @data = current_user.checkout(bill_params, package_attrs: package_params)
      @bill = @data[:bill]
      @orders = @data[:orders]
    end
  end

  private

  def bill_params
    params.require(:bill).permit(:type, :invoice_type, :invoice_code, :invoice_cert, :invoice_love_code, :invoice_uni_num)
  end

  def package_params
    params.fetch(:package, ActionController::Parameters.new).permit(:recipient_name, :pickup_address, :recipient_mobile, :pickup_datetime, additional_items: %w(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16))
  end
end
