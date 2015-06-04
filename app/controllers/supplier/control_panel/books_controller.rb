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
        collection = current_supplier_staff.books.includes(:data)
        collection = filter(collection)
        pagination collection,
                   default_per_page: 25,
                   maxium_per_page: 1000
        @books = collection.order(sort).page(page).per(per_page)
        render :book
      end
    end
  end
end
