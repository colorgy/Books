class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    current_user.check_cart!
    @cart_items = current_user.cart_items.includes(:book, :course)

    respond_to do |format|
      format.html
      format.json { render json: @cart_items }
    end
  end

  def create
    current_user.check_cart!

    book = Book.find(params[:book_id])
    course = Course.find(params[:course_id])
    @cart_item = current_user.cart_items.create!(book: book, course: course)

    respond_to do |format|
      format.html do
        flash[:notice] = "已經將 #{@cart_item.book_name} 加入購物書包～"
        redirect_to :back
      end
      format.json { render json: @cart_item }
    end
  end

  def destroy
    current_user.check_cart!

    @cart_item = current_user.cart_items.find(params[:id]).destroy!

    respond_to do |format|
      format.html do
        flash[:notice] = "已經將 #{@cart_item.book_name} 移出購物書包～"
        redirect_to :back
      end
      format.json { render json: @cart_item }
    end
  end
end
