class Supplier::ControlPanel::BooksController < Supplier::ControlPanelController
  include APIHelpers::Filterable
  include APIHelpers::Paginatable
  include APIHelpers::Sortable

  def index
    @orgs = Organization.all
    sortable default_order: { isbn: :asc }
    pagination current_supplier_staff.books,
               default_per_page: 25,
               maxium_per_page: 1000

    respond_to do |format|
      format.html do
      end

      format.json do
        collection = current_supplier_staff.books.includes(:data)
        @books = filter(collection).order(sort).page(page).per(per_page)
        render :book
      end
    end
  end
end
