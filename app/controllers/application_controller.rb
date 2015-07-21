class ApplicationController < ActionController::Base
  include ColorgyDeviseSSOManager
  include FlashMessageReporter

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_org_code

  if ENV['DISABLE_SSO'] == 'true'
    before_filter :sso_off!
  end

  private

  def current_org_code
    if current_user && current_user.organization_code.present?
      current_user.organization_code
    else
      'public'
    end
  end
end
