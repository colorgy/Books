class CreditsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user_credits = current_user.user_credits
  end

  def tutorabc_check
  	return if current_user.tutorabc_check_credits
		current_user.user_credits.build(name: 'TutorABC獎助學生計畫', credits: 50)
		current_user.tutorabc_check_credits = true
		current_user.save!

    respond_to do |format|
      format.json { render json:
        {
          status: "成功獲得 tutorABC 提供之 50 元購書金！"
        }
      }
    end
  end

  def colorgy_books_share
  	return if current_user.share_colorgy_books_credits
		current_user.user_credits.build(name: '分享 Colorgy Books', credits: 50)
		current_user.share_colorgy_books_credits = true
		current_user.save!
    respond_to do |format|
      format.json { render json:
        {
          status: "成功獲得 Colorgy 提供之 50 元購書金！"
        }
      }
    end
  end

  def taiwan_mobile
    user_id = params[:user_id]
    @user = User.all.find(user_id)
    return if @user.taiwan_mobile_credits
    @user.user_credits.build(name: '時空訊息感謝爸媽任務', credits: 50)
    @user.taiwan_mobile_credits = true
    @user.save!
    respond_to do |format|
      format.json { render json:
        {
          status: "成功獲得 時空訊息 提供之 50 元購書金！"
        }
      }
    end

  end
end
