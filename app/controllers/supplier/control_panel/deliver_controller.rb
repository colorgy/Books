class Supplier::ControlPanel::DeliverController < Supplier::ControlPanelController
  include APIHelpers::Filterable
  include APIHelpers::Paginatable
  include APIHelpers::Sortable

  def index
  end

  def create
  end

  def update
  end

  def destroy
  end

  private

  def scoped_collection
  end

  def group_params
  end
end
