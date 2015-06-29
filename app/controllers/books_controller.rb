class BooksController < ApplicationController
  before_action :authenticate_user!, except: :index
  layout 'front'

  def index
    render :landing and return if current_user.blank?
    @org_code = current_org_code
    @dep_code = params[:dep]
    if @dep_code.present?
      @org = Organization.find(@org_code)
      @dep = @org.departments
      @dep_codes = @dep_code.split(',')
      @all_dep_codes = @dep.map(&:code)
      @dep_codes &= @all_dep_codes
    end

    if @dep_codes.present?
      @courses = Course.current.where(organization_code: @org_code, department_code: @dep_codes)
    else
      @courses = Course.current.where(organization_code: @org_code)
    end

    if params[:q].blank?
      @book_isbns = @courses.map(&:book_isbn)
      @book_isbns.reject!(&:blank?)
      @books = Book.includes(:data).where(isbn: @book_isbns)
    else
      @book_isbns = []
      query = params[:q]
      query.downcase!
      queries = query.split(' ')[0..4]
      c = @courses.where('lower(name) LIKE ? OR lower(lecturer_name) LIKE ?', "%#{query}%", "%#{query}%")
      @book_isbns << c.map(&:book_isbn)
      queries.each do |q|
        c = @courses.where('lower(name) LIKE ? OR lower(lecturer_name) LIKE ?', "%#{q}%", "%#{q}%")
        @book_isbns << c.map(&:book_isbn)
      end
      @book_datas = BookData.search(query)
      @book_isbns << @book_datas.map(&:isbn)
      @book_isbns.reject!(&:blank?)
      @books = Book.includes(:data).where(isbn: @book_isbns)
    end
  end

  def show
    @book = Book.includes(:data).find(params[:id])
  end
end
