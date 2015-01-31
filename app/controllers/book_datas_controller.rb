class BookDatasController < ApplicationController

  def index
    if params[:q]
      @book_datas = BookData.search(params[:q])
    else
      @book_datas = []
    end
  end

  def show
    @book_data = BookData.find_by(isbn: params[:id])
  end
end
