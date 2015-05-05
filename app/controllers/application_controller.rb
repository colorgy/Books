class ApplicationController < ActionController::Base
  include ColorgyDeviseSSOManager
  include FlashMessageReporter

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_org
  helper_method :current_org_code

  private

  def current_org_code
    session[:current_org_code] || (current_user && current_user.organization_code) || 'NTUST'
  end

  def set_org
    return unless params[:org]
    session[:current_org_code] = params[:org]
  end
end
