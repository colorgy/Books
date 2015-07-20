class CourseSelectionsController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:q].present?
      q = params[:q]
      q = "%#{q}%"
      @courses = courses_collection.where('name LIKE ? OR lecturer_name LIKE ?', q, q)
    else
      @courses = courses_collection.order('RANDOM()').first(10)
    end

    @course_selections = @courses.map { |course| { label: "#{course.name} / #{course.lecturer_name}", value: course.ucode } }
    render json: @course_selections
  end

  private

  def courses_collection
    Course.current.in_org(current_user.organization_code)
  end
end
