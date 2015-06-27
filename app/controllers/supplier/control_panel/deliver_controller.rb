class Supplier::ControlPanel::DeliverController < Supplier::ControlPanelController
  include APIHelper::Filterable
  include APIHelper::Paginatable
  include APIHelper::Sortable

  def index
    @orgs = Organization.all

    sortable default_order: { pickup_datetime: :desc }
    collection = scoped_collection
    collection = filter(collection)
    pagination collection,
               default_per_page: 25,
               maxium_per_page: 1000
    @groups = collection.order(sort).page(page).per(per_page)

    respond_to do |format|
      format.html
      format.json { render :group }
    end
  end

  def create
  end

  def update
    @group = scoped_collection.find_by(code: params[:id])
    if params[:event]
      case params[:event]
      when 'ship'
        @group.ship!
      end
    end

    respond_to do |format|
      format.html
      format.json { render :group }
    end
  end

  def destroy
  end

  private

  def scoped_collection
    current_supplier_staff.groups.includes(:orders, :course)
  end

  def group_params
  end
end
