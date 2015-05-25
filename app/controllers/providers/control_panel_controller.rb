class Providers::ControlPanelController < ActionController::Base
  layout 'provider_cp'
  before_action :authenticate_provider!
  before_action :find_current_path

  def find_current_path
    @current_path = request.env['PATH_INFO']
  end
end
