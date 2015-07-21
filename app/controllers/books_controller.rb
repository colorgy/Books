class BooksController < ApplicationController
  before_action :authenticate_user!

  def index

    if params[:q].blank?
      @books = books_collection.all
    else
      # prepare the query
      query = params[:q]
      query.downcase!
      queries = query.split(' ')[0..4]
      queries << query if queries.count > 1

      # create a list to save matching ISBNs
      @book_isbns = []

      # search through the courses
      @courses = []
      queries.each do |q|
        @courses += courses_collection.simple_search(q)
      end
      @courses.each do |course|
        course.course_books.each do |course_book|
          @book_isbns << course_book.book_isbn
        end
      end

      # search through the book_data
      @book_data = []
      queries.each do |q|
        @book_data += BookData.simple_search(q)
      end
      @book_isbns += @book_data.map(&:isbn)

      @book_isbns.reject!(&:blank?)

      @books = []
      @books += Book.includes(data: [:courses]).where(id: query)
      @books += Book.includes(data: [:courses]).where(isbn: @book_isbns)
    end
    # @org_code = current_org_code
    # @dep_code = params[:dep]
    # if @dep_code.present?
    #   @org = Organization.find(@org_code)
    #   @dep = @org.departments
    #   @dep_codes = @dep_code.split(',')
    #   @all_dep_codes = @dep.map(&:code)
    #   @dep_codes &= @all_dep_codes
    # end

    # if @dep_codes.present?
    #   @courses = Course.current.where(organization_code: @org_code, department_code: @dep_codes)
    # else
    #   @courses = Course.current.where(organization_code: @org_code)
    # end

    # if params[:q].blank?
    #   @book_isbns = @courses.map(&:book_isbn)
    #   @book_isbns.reject!(&:blank?)
    #   @books = Book.includes(:data).where(isbn: @book_isbns)
    # else
    #   @book_isbns = []
    #   query = params[:q]
    #   query.downcase!
    #   queries = query.split(' ')[0..4]
    #   c = @courses.where('lower(name) LIKE ? OR lower(lecturer_name) LIKE ?', "%#{query}%", "%#{query}%")
    #   @book_isbns << c.map(&:book_isbn)
    #   queries.each do |q|
    #     c = @courses.where('lower(name) LIKE ? OR lower(lecturer_name) LIKE ?', "%#{q}%", "%#{q}%")
    #     @book_isbns << c.map(&:book_isbn)
    #   end
    #   @book_datas = BookData.search(query)
    #   @book_isbns << @book_datas.map(&:isbn)
    #   @book_isbns.reject!(&:blank?)
    #   @books = Book.includes(:data).where(isbn: @book_isbns)
    # end
  end

  def show
    @book = Book.includes(:data).find(params[:id])
    @book_groups = @book.groups.in_org(current_org_code)
    @book_group_course_ucodes = @book_groups.map(&:course_ucode)
    @book_groups = ActiveModel::ArraySerializer.new(@book_groups, each_serializer: GroupSerializer).as_json

    @book_courses = @book.courses.current.in_org(current_org_code)
    @book_courses_with_no_group = @book_courses.to_a.delete_if { |course| @book_group_course_ucodes.include?(course.ucode) }
  end

  private

  def books_collection
    Book.for_org(current_org_code)
  end

  def courses_collection
    Course.current.where(organization_code: current_org_code)
  end
end
