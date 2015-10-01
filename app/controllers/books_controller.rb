class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    # @cached_page = Rails.cache.fetch("#{current_org_code}/books_page/#{params[:q]}/#{params[:page]}", expires_in: 10.minutes) do

      if params[:q].present? && params[:q].is_a?(String)
        @books = books_collection.simple_search(params[:q], current_org_code).page(params[:page])
        @course_with_no_book = Course.current.in_org(current_user.organization_code).no_book.simple_search(params[:q]).limit(5)
        @books = books_collection.order(:display_order).page(params[:page]) if @books.blank?
      else
        @books = books_collection.order(:display_order).page(params[:page])
      end

      # render_to_string(layout: false)
    # end
  end

  def show
    @book = books_collection.includes(:data).find(params[:id])
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
    if ["TTU", "CGU", "GCU", "NTPU", "NCKU", "NCU", "NCHU", "YZU", "FJU", "TKU", "CCU", "NSYSU", "NTHU", "NCTU", "NTUST", "NTUT", "CYCU", "NTU", "NTNU"].include?(current_org_code)
      if %w(NCU NCHU YZU FJU).include?(current_org_code)
        Book.for_org(current_org_code).where.not(isbn: '9789574328154').includes_full_data
      else
        Book.for_org(current_org_code).includes_full_data
      end
    else
      Book.where(id: [802410, 389478])
    end
  end

  def courses_collection
    Course.current.where(organization_code: current_org_code)
  end
end
