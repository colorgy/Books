class LecturerCoursesController < ApplicationController
  before_action :authenticate_user!

  def index
    @lecturer_courses = current_user.identities.find(params[:lecturer_id]).courses.includes(:book_data)
  end

  def new
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.build
    @lecturer_course.organization_code = @id.organization_code

    @lecturer_course.department_code = @id.department_code
    @lecturer_course.year = Time.now.year
    @lecturer_course.term = (Time.now.month > 6) ? 1 : 2
  end

  def create
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.build(course_params)
    @lecturer_course.organization_code = @id.organization_code

    if @lecturer_course.book_data.blank?
      @lecturer_course.unknown_book_name = @lecturer_course.book_isbn.gsub('NEW+>', '')
      @lecturer_course.book_isbn = nil
    end

    if @lecturer_course.save
      @lecturer_course.confirm_book!
      redirect_to lecturer_courses_path(params[:lecturer_id]), notice: 'Course was successfully created.'
    else
      if @lecturer_course.book_isbn.blank? && !@lecturer_course.unknown_book_name.blank?
        @lecturer_course.book_isbn = 'NEW+>' + @lecturer_course.unknown_book_name
      end
      render :new
    end
  end

  def edit
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.find(params[:id])

    if @lecturer_course.book_isbn.blank? && !@lecturer_course.unknown_book_name.blank?
      @lecturer_course.book_isbn = 'NEW+>' + @lecturer_course.unknown_book_name
    end
  end

  def update
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.find(params[:id])

    if @lecturer_course.book_data.blank?
      @lecturer_course.unknown_book_name = @lecturer_course.book_isbn.gsub('NEW+>', '')
      @lecturer_course.book_isbn = nil
    end

    if @lecturer_course.save
      @lecturer_course.confirm_book!
      redirect_to lecturer_courses_path(params[:lecturer_id]), notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  private

  def course_params
    params.require(:course).permit(:department_code, :year, :term, :name, :code, :url, :required, :book_isbn, :unknown_book_name)
  end
end
