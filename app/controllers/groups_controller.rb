class GroupsController < ApplicationController
  before_action :authenticate_user!

  def index
    @groups = current_user.lead_groups
  end

  def show
    @group = current_user.lead_groups.find(params[:id])
    @orders = @group.orders
  end

  def new
    @course = Course.find(params[:course])
    @book = Book.find(params[:book])
  end

  def create
    @group = current_user.lead_course_group(params[:course], params[:book])
    redirect_to @group
  end
end
