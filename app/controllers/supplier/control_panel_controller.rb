class Supplier::ControlPanelController < ActionController::Base
  layout 'supplier_cp'
  before_action :authenticate_supplier_staff!
  before_action :find_current_path
  helper_method :grouping_orders_count, :pending_orders_count

  def find_current_path
    @current_path = request.env['PATH_INFO']
  end

  def grouping_orders_count
    @grouping_orders_count ||= scoped_orders.grouping.count
  end

  def pending_orders_count
    @pending_orders_count ||= scoped_orders.ended.unshipped.count
  end

  def scoped_orders
    current_supplier_staff.groups
  end
end
