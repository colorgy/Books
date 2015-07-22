class OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    @cart_items = current_user.cart_items.includes_default

    redirect_to root_path and return if @cart_items.blank?

    if params[:confirmed]
      # really checkout
      @data = current_user.checkout!(bill_params, package_attrs: package_params)
    else
      # let the user to confirm their order
      @data = current_user.checkout(bill_params, package_attrs: package_params)
    end
  end

  private

  def bill_params
    params.require(:bill).permit(:type, :invoice_type, :invoice_code, :invoice_cert, :invoice_love_code, :invoice_uni_num)
  end

  def package_params
    params.fetch(:package, ActionController::Parameters.new).permit(:recipient_name, :pickup_address, :recipient_mobile, :pickup_datetime)
  end
end
