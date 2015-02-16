class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :verify_identity_token, :set_flash_message_from_params

  private

  def verify_identity_token
    # skip this on test and auth callbacks
    return if Rails.env.test?
    return if params[:controller] == 'users/omniauth_callbacks'
    request_identity_token = cookies[:_identity_token]
    ignored_identity_token = cookies[:_ignored_identity_token]

    if user_signed_in?

      # if the user's session is valid but the identity_token is blank,
      # sign out the user
      if request_identity_token.blank?
        sign_out current_user

      # if the user's session is valid and the identity_token is blank,
      # check if the identity_token is valid
      else
        # split it and get the hash & timestamp
        request_identity_token_split = request_identity_token.split('.')
        request_identity_token_hash = request_identity_token_split[0]
        request_identity_token_timestamp = request_identity_token_split[1]
        data_update_time = request_identity_token_split[2]
        token_generate_time = Time.at(request_identity_token_timestamp.to_i)

        # generate a token with provided parameters to compare it with the identity_token
        identity_token_hash = Digest::MD5.hexdigest(current_user.sid.to_s + Digest::MD5.hexdigest(identity_token_secret_key + request_identity_token_timestamp))

        # check if they're matched, sign out the user if isn't
        if request_identity_token_hash != identity_token_hash
          sign_out current_user
          token_generate_time = Time.at(0)
        end

        # if current user's update time is older then the token specified time,
        # re-authentication to refresh the user's data
        data_update_time = data_update_time.blank? ? 1.years.ago : Time.at(data_update_time.to_i)
        if (current_user.blank? || current_user.refreshed_at.blank? || data_update_time > current_user.refreshed_at) &&
           request.get?
          sign_out current_user
          redirect_to user_omniauth_authorize_path(:colorgy) and return
        end

        # if the token is too old and the current HTTP method is redirectable,
        # redirect to core to refresh it
        # refresh it anyway if the token has expired
        if (Time.now - token_generate_time > 7.days) ||
           (Time.now - token_generate_time > 3.days && request.get?)
          redirect_to ENV['CORE_URL'] + "/refresh_it?redirect_to=#{CGI.escape(request.original_url)}" and return
        end
      end

    # if the user isn't signed in but the identity_token isn't blank,
    # redirect to core authorize path
    elsif !request_identity_token.blank? && (request_identity_token != ignored_identity_token)
      redirect_to user_omniauth_authorize_path(:colorgy) and return
    end
  end

  def identity_token_secret_key
    @site_secret ||= Digest::MD5.hexdigest(ENV['SITE_SECRET'])[0..16]
  end

  def set_flash_message_from_params
    referer_uri = request.env["HTTP_REFERER"] ? URI.parse(request.env["HTTP_REFERER"]) : nil
    return unless params[:flash] && referer_uri && referer_uri.host.ends_with?(core_domain)

    flash[:notice] = params[:flash][:notice] if params[:flash][:notice]
    flash[:alert] = params[:flash][:alert] if params[:flash][:alert]
  end

  def core_domain
    @domain ||= URI.parse(ENV['CORE_URL']).host
  end
end
