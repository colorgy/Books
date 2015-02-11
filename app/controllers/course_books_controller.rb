class CourseBooksController < ApplicationController

  def index
    if (params[:org].present? && params[:lecturer].present?)
      @courses = Course
                 .select(:id, :organization_code, :department_code, :lecturer_name, :year, :term, :name, :code, :url, :required, :book_isbn, :unknown_book_name, :confirmed_at)
                 .where('organization_code = ? AND lecturer_name LIKE ?', params[:org], "%#{params[:lecturer]}%")
                 .limit(1000)
                 .map(&:to_edit)
    end

    respond_to do |format|
      format.html
      format.js
      format.json { render json: @courses }
    end
  end

  def update
    @course = Course.unconfirmed.find(params[:id])
    Rails.logger.info @course
    Rails.logger.info params
    @course.update(course_params)
    respond_to do |format|
      format.json { render json: @course }
    end
  end

  private

  def course_params
    params.require(:course).permit(:name, :url, :required, :book_isbn)
  end
end
