class Supplier::ControlPanel::BooksController < Supplier::ControlPanelController
  include APIHelpers::Filterable
  include APIHelpers::Paginatable
  include APIHelpers::Sortable

  def index
    sortable default_order: { isbn: :asc }
    pagination current_supplier_staff.books,
               default_per_page: 25,
               maxium_per_page: 1000

    respond_to do |format|
      format.html do
      end

      format.json do
        @books = filter(current_supplier_staff.books).order(sort).page(page).per(per_page)
        render json: @books
      end
    end
  end
end
