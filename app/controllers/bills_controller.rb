class BillsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bills = current_user.bills
  end

  def show
    @bill = current_user.bills.find(params[:id])
    @orders = @bill.orders
  end

  def create
    @checkout_data = current_user.checkout(bill_params)
    @bill = @checkout_data[:bill]
    @orders = @checkout_data[:orders]

    flash[:alert] = '付款方式或發票資料有誤！' and redirect_to cart_items_path and return unless @bill.valid?
    flash[:alert] = '沒有可以結帳的書～' and redirect_to cart_items_path and return if @orders.blank?
    render :confirm and return unless params[:confirmed]

    ActiveRecord::Base.transaction do
      @bill.save!
      @orders.each do |order|
        order.save_with_bill!(@bill)
      end
      current_user.use_credit!(@bill.used_credits) if @bill.used_credits.present?
      current_user.clear_cart!
    end

    redirect_to bill_path(@bill)
  end

  private

  def bill_params
    params.require(:bill).permit(:type, :invoice_type, :invoice_code, :invoice_cert, :invoice_love_code, :invoice_uni_num)
  end
end
