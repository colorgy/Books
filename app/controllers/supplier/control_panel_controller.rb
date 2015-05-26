class Supplier::ControlPanelController < ActionController::Base
  layout 'supplier_cp'
  before_action :authenticate_supplier_staff!
  before_action :find_current_path

  def find_current_path
    @current_path = request.env['PATH_INFO']
  end
end
