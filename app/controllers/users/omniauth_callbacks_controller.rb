class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def colorgy
    auth = request.env["omniauth.auth"]

    if !['student', 'professor', 'lecturer', 'staff'].include?(auth.info.identity)
      cookies[:_ignored_identity_token] = cookies[:_identity_token]
      redirect_to sorry_but_forbidden_path, notice: '很抱歉，本服務尚未開放您使用！' and return
    end

    @user = User.from_core(auth)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Colorgy") if is_navigational_format?
    else
      flash[:alert] = '登入失敗'
    end
  end
end
