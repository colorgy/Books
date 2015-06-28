class LecturerBooks::CoursesController < ApplicationController
  before_filter :check_params
  skip_before_action :verify_authenticity_token

  def index
    @courses = scoped_collection.all
    @courses_array = @courses.as_json(include: :course_book, methods: :possible_course_book)
    @courses_hash = Hash[@courses_array.map { |c| [c['ucode'], c] }]
    render json: @courses_hash
  end

  def update
    @course = scoped_collection.find_by(ucode: params[:id])
    if @course.update_attributes(course_params)
      render json: @course.as_json(include: :course_book, methods: :possible_course_book)
    else
      render json: @course.as_json(include: :course_book, methods: :possible_course_book), status: 400
    end
  end

  private

  def scoped_collection
    Course.includes(:course_book).current.where('organization_code = ? AND lecturer_name LIKE ?', params[:org], "%#{params[:lecturer]}%")
  end

  def check_params
    if params[:lecturer].blank? || params[:org].blank?
      render json: [] and return
    end
  end

  def course_params
    params.require(:course).permit(course_book_attributes: [:id, :book_isbn, :book_known, :_delete])
  end
end
