class CreditsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_credits = current_user.user_credits
  end
end
