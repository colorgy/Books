class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def colorgy
    auth = request.env["omniauth.auth"]
    @user = User.from_core(auth)
    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Colorgy") if is_navigational_format?
    else
      flash[:alert] = '登入失敗'
    end
  end
end
