class BookDatasController < ApplicationController

  def index
    if params[:q]
      @book_datas = BookData.simple_search(params[:q]).limit(25)
    else
      @book_datas = []
    end
  end

  def show
    @book_data = BookData.find_by(isbn: params[:id])
  end
end
