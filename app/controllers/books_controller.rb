class BooksController < ApplicationController
  before_action :authenticate_user!

  def index
    if params[:q].blank?
      @books = Book.all
    else
    end
  end

  def show
    @book = Book.find(params[:id])
  end
end
