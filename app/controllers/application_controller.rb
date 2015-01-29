class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :verify_identity_token

  private

  def verify_identity_token
    return if Rails.env.test?
    return if params[:controller] == 'users/omniauth_callbacks'
    if user_signed_in?
      if cookies[:_identity_token].blank?
        sign_out current_user
      else
        identity_token = Digest::MD5.hexdigest("#{current_user.sid}#{Digest::MD5.hexdigest(ENV['SITE_SECRET'])[0..16] + Date.today.year.to_s + Date.today.strftime('%U')}")
        if cookies[:_identity_token] != identity_token
          redirect_to ENV['CORE_URL'] + "/refresh_it?redirect_to=#{CGI.escape(request.original_url)}"
        end
      end
    elsif !cookies[:_identity_token].blank?
      redirect_to user_omniauth_authorize_path(:colorgy)
    end
  end
end
