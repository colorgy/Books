class BooksController < ApplicationController
  before_action :authenticate_user!

  def index

    if params[:q].present? && params[:q].is_a?(String)
      @books = books_collection.simple_search(params[:q], current_org_code).page(params[:page])
    else
      @books = books_collection.page(params[:page])
    end
  end

  def show
    @book = Book.includes(:data).find(params[:id])
    @book_groups = @book.groups.grouping.in_org(current_org_code)
    @book_group_course_ucodes = @book_groups.map(&:course_ucode)
    @book_groups = ActiveModel::ArraySerializer.new(@book_groups, each_serializer: GroupSerializer).as_json

    @book_courses = @book.courses.current.in_org(current_org_code)
    @book_courses_with_no_group = @book_courses.to_a.delete_if { |course| @book_group_course_ucodes.include?(course.ucode) }
  end

  def search_suggestions
    query = params[:q]
    results = []

    match_courses = Course.current.in_org(current_user.organization_code).simple_search(query).limit(25)

    results += match_courses.map { |c| "#{c.name} - #{c.lecturer_name}" }.uniq
    results += match_courses.map { |c| c.lecturer_name }.uniq

    render json: results
  end

  private

  def books_collection
    Book.for_org(current_org_code).includes_full_data
  end

  def courses_collection
    Course.current.where(organization_code: current_org_code)
  end
end
