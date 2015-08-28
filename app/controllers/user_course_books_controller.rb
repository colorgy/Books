class UserCourseBooksController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def new
    @course = Course.find_by(ucode: params[:course_ucode])
    @book_data = BookData.find_by(isbn: params[:book_isbn])
    @course_book = CourseBook.new
    @course_book.course = @course if @course
    @course_book.book_data = @book_data if @book_data
  end

  def create
    @course_book = CourseBook.new(course_book_params)
    if @course_book.course.course_books.present?
      course = @course_book.course
      @course_book = course.course_books.last
      @course_book.assign_attributes(course_book_params)
    end

    @course_book.updater_type = 'user'
    @course_book.updater_code = current_user.id

    ActiveRecord::Base.transaction do
      @course_book.save!
      current_user.user_credits.create(credits: 50, book_isbn: @course_book.book_isbn)
    end

    @book = Book.for_org(current_org_code).find_by(isbn: @course_book.book_isbn)

    flash[:success] = "成功回報課程用書！您在購買「#{@course_book.book_data.name}」時將可以享 NT$ 50 折扣！"

    if @book
      redirect_to book_path(@book)
    else
      redirect_to root_path
    end
  end

  def edit
    @course = Course.find_by(ucode: params[:course_ucode])
    @book_data = BookData.find_by(isbn: params[:book_isbn])
    @course_book = CourseBook.new
    @course_book.course = @course.course_book.first if @course
    @course_book.book_data = @book_data if @book_data
  end

  private

  def course_book_params
    params.require(:course_book).permit(:book_isbn, :course_ucode)
  end
end
