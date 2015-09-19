class GroupBuyFormsController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def new
    @group_buy_form = current_user.group_buy_forms.build
    @group_buy_form.course = @course if @course
    @group_buy_form.book_isbn = params[:book_isbn]
  end

  def create
    @group_buy_form = current_user.group_buy_forms.build(group_buy_form_params)

    if @group_buy_form.save
      flash[:success] = '收到了，我們會聯繫您有關訂購的事項！'
      redirect_to root_path
    else
      render :new
    end
  end

  private

  def group_buy_form_params
    params.require(:group_buy_form).permit(:book_isbn, :course_ucode, :course_name, :quantity)
  end
end
