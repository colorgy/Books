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
  	return if current_user.taiwan_mobile_credits
		current_user.user_credits.build(name: '下載時空訊息 APP', credits: 50)
		current_user.taiwan_mobile_credits = true
		current_user.save!
    respond_to do |format|
      format.json { render json:
        {
          status: "成功獲得 台灣大哥大 提供之 50 元購書金！"
        }
      }
    end
  end
end
