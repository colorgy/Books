class Supplier::SessionsController < Devise::SessionsController
  layout 'supplier'

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || supplier_control_panel_dashboard_path
  end

  def after_sign_out_path_for(_)
    supplier_control_panel_dashboard_path
  end
end
