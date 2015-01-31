class LecturerController < ApplicationController
  before_action :authenticate_user!

  def index
    @ids = current_user.identities.lecturer
    redirect_to lecturer_path(@ids.first) if @ids.count == 1
  end

  def show
    redirect_to lecturer_courses_path(params[:id])
  end
end
