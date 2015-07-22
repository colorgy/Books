class CartItemsController < ApplicationController
  before_action :authenticate_user!, :check_if_open_for_orders!

  def index
    current_user.check_cart!
    @cart_items_data = cart_items_data

    respond_to do |format|
      format.html
      format.json { render json: cart_items_data }
    end
  end

  def create
    @cart_item = current_user.add_to_cart(cart_item_params[:item_type], cart_item_params[:item_code], quantity: cart_item_params[:quantity], course_ucode: cart_item_params[:course_ucode])

    respond_to do |format|
      format.html do
        flash[:notice] = "已經將 #{@cart_item.book_name} 加入購物書包～"
        redirect_to :back
      end
      format.json { render json: cart_items_data }
    end
  end

  def update
    @cart_item = current_user.cart_items.find(params[:id])
    updated = @cart_item.update(cart_item_params)
    current_user.check_cart!

    respond_to do |format|
      if updated
        format.html { redirect_to @cart_item, notice: 'cart_item was successfully updated.' }
        format.json { render json: cart_items_data }
      else
        format.html { render :edit }
        format.json { render json: cart_items_data }
      end
    end
  end

  def destroy
    @cart_item = current_user.cart_items.find(params[:id]).destroy!
    current_user.check_cart!

    respond_to do |format|
      format.html do
        flash[:notice] = "已經將 #{@cart_item.book_name} 移出購物書包～"
        redirect_to :back
      end
      format.json { render json: cart_items_data }
    end
  end

  private

  def cart_item_params
    @cart_item_params ||= params.require(:cart_item).permit(:quantity, :item_type, :item_code, :course_ucode)
  end

  def cart_items_data
    @cart_items_data ||= ActiveModel::ArraySerializer.new(current_user.cart_items.includes_default, each_serializer: CartItemSerializer).as_json
  end
end
