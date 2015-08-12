class CourseBooks::BookDataSelectionsController < ApplicationController
  before_filter :check_params

  def index
    @book_data = BookData.simple_search(params[:q]).includes(book: [:supplier]).limit(100)
    @selections = @book_data.map { |data| { value: data.isbn, label: <<-EOS
        <img src="#{data.image_url}" />
        <span class="info">
          <span class="annotation">書名</span>
          #{data.name}
        </span>
        <span class="info">
          <span class="annotation">作者</span>
          #{data.author}
        </span>
        <span class="info">
          <span class="annotation">ISBN</span>
          #{data.isbn}
        </span>
        <span class="info">
          <span class="annotation">代理商</span>
          #{data.supplier_name || '未知'}
        </span>
      EOS
    } }
    @selections = [{ value: "#{params[:q]}", label: <<-EOS
      <img src="https://placeholdit.imgix.net/~text?txtsize=300&txt=?&w=400&h=500" />
      #{params[:q]}
      <span class="annotation">
        (此本書尚未在我們的資料庫中登錄，但您仍然可以選擇它，請盡量填入完整資料！)
      </span>
      EOS
    }] if @selections.blank?
    render json: @selections
  end

  private

  def check_params
    if params[:q].blank?
      render json: [] and return
    end
  end
end
