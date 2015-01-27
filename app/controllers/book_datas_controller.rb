class BookDatasController < ApplicationController
  before_action :set_book_data, only: [:show, :edit, :update, :destroy]

  # GET /book_datas
  # GET /book_datas.json
  def index
    @book_datas = BookData.all
  end

  # GET /book_datas/1
  # GET /book_datas/1.json
  def show
  end

  # GET /book_datas/new
  def new
    @book_data = BookData.new
  end

  # GET /book_datas/1/edit
  def edit
  end

  # POST /book_datas
  # POST /book_datas.json
  def create
    @book_data = BookData.new(book_data_params)

    respond_to do |format|
      if @book_data.save
        format.html { redirect_to @book_data, notice: 'Book data was successfully created.' }
        format.json { render :show, status: :created, location: @book_data }
      else
        format.html { render :new }
        format.json { render json: @book_data.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /book_datas/1
  # PATCH/PUT /book_datas/1.json
  def update
    respond_to do |format|
      if @book_data.update(book_data_params)
        format.html { redirect_to @book_data, notice: 'Book data was successfully updated.' }
        format.json { render :show, status: :ok, location: @book_data }
      else
        format.html { render :edit }
        format.json { render json: @book_data.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /book_datas/1
  # DELETE /book_datas/1.json
  def destroy
    @book_data.destroy
    respond_to do |format|
      format.html { redirect_to book_datas_url, notice: 'Book data was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book_data
      @book_data = BookData.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def book_data_params
      params.require(:book_data).permit(:isbn, :name, :edition, :author, :image_url, :publisher, :price)
    end
end
