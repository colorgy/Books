class LecturerCoursesController < ApplicationController
  before_action :authenticate_user!

  def index
    @lecturer_courses = current_user.identities.find(params[:lecturer_id]).courses.includes(:book_data)
  end

  def new
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.build
  end

  def create
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.build(course_params)

    if @lecturer_course.save
      @lecturer_course.confirm!
      redirect_to lecturer_courses_path(params[:lecturer_id]), notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  def edit
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.find(params[:id]).to_edit
  end

  def update
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.find(params[:id])

    if @lecturer_course.update(course_params)
      @lecturer_course.confirm!
      redirect_to lecturer_courses_path(params[:lecturer_id]), notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @id = current_user.identities.find(params[:lecturer_id])
    @lecturer_course = @id.courses.find(params[:id])
    @lecturer_course.destroy
    redirect_to lecturer_courses_path(params[:lecturer_id]), notice: '課程資料已刪除！'
  end

  private

  def course_params
    params.require(:course).permit(:department_code, :year, :term, :name, :code, :url, :required, :book_isbn, :unknown_book_name)
  end
end
