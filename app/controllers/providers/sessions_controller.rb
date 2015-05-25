class Providers::SessionsController < Devise::SessionsController
  layout 'provider'

  def after_sign_in_path_for(_)
    providers_control_panel_dashboard_path
  end

  def after_sign_out_path_for(_)
    providers_control_panel_dashboard_path
  end
end
