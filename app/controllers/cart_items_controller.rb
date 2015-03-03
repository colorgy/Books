class CartItemsController < ApplicationController
  before_action :authenticate_user!

  def index
    current_user.check_cart!
    @cart_items = current_user.cart_items.includes(:book, :course)
    @group_codes = []
    @group_datas = {}

    @cart_items.each do |item|
      group_code = BatchCodeService.generate_group_code(item.course.organization_code, item.course_id, item.book_id)
      @group_codes << group_code
      @group_datas[group_code] = { book_id: item.book_id, course_id: item.course_id, course_name: item.course_name, course_lecturer_name: item.course_lecturer_name }
    end

    @existing_groups = Group.where(code: @group_codes)
    @existing_group_codes = @existing_groups.map(&:code)

    @new_group_datas = @group_datas.delete_if { |k, v| @existing_group_codes.include?(k) }

    respond_to do |format|
      format.html
      format.json { render json: @cart_items }
    end
  end

  def create
    current_user.check_cart!

    book = Book.find(params[:book_id])
    course = Course.find(params[:course_id])
    quantity = (params[:quantity] || 1).to_i
    @cart_item = current_user.add_to_cart(book, course, quantity)

    if course.book_data.blank?
      course.book_isbn = book.isbn
      course.updated_through = 'add_to_cart'
      course.save!
    end

    @cart_item ||= { error: 'not_created' }

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
