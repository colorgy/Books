class LecturerBooks::BookDataSelectionsController < ApplicationController
  before_filter :check_params

  def index
    @book_data = BookData.search(params[:q])
    @selections = @book_data.map { |data| { value: data.isbn, label: "#{data.name} - #{data.author} (#{data.isbn})" } }
    @selections = [{ value: "#{params[:q]}   ", label: "#{params[:q]}" }] if @selections.blank?
    render json: @selections
  end

  private

  def check_params
    if params[:q].blank?
      render json: [] and return
    end
  end
end
