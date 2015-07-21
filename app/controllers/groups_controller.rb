class GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    @groups = current_user.lead_groups
  end

  def show
    @group = current_user.lead_groups.find(params[:id])
    @orders = @group.orders.order(:state)
  end

  def new
    @course = Course.find_by(ucode: params[:course_ucode])
    @book = Book.find_by(id: params[:book_id])
    @group = Group.new(book: @book, course: @course)
  end

  def create
    @group = current_user.lead_group(Group.new(new_group_params))
    redirect_to @group
  end

  def edit
    @group = current_user.lead_groups.find(params[:id])
  end

  def update
    @group = current_user.lead_groups.find(params[:id])
    if @group.update(group_params)
      redirect_to @group
    else
      render :show
    end
  end

  private

  def new_group_params
    params.require(:group).permit(:book_id, :course_ucode, :recipient_name, :recipient_mobile, :pickup_point, :pickup_datetime)
  end

  def group_params
    params.require(:group).permit(:recipient_name, :recipient_mobile, :pickup_point, :pickup_datetime)
  end
end
