class Supplier::ControlPanel::BooksController < Supplier::ControlPanelController
  include APIHelpers::Filterable
  include APIHelpers::Paginatable
  include APIHelpers::Sortable

  def index
    @orgs = Organization.all

    respond_to do |format|
      format.html do
      end

      format.json do
        sortable default_order: { internal_code: :asc, isbn: :asc }
        collection = scoped_collection
        collection = filter(collection)
        pagination collection,
                   default_per_page: 25,
                   maxium_per_page: 1000
        @books = collection.order(sort).page(page).per(per_page)
        render :book
      end
    end
  end

  def update
    @book = scoped_collection.find(params[:id])
    respond_to do |format|
      if @book.update(book_params)
        format.json { render :book }
      else
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def scoped_collection
    current_supplier_staff.books.includes(:data)
  end

  def book_params
    params.require(:book).permit(:isbn, :price, :internal_code)
  end
end
