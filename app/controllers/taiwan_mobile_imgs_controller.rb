class TaiwanMobileImgsController < ApplicationController
	before_action :authenticate_user!

	def create
		if current_user.taiwan_mobile_credits
			flash[:error] = '你已經上傳過了唷！'
			return
		end
		@taiwan_mobile_img = current_user.taiwan_mobile_imgs.new(taiwan_mobile_imgs_params)

		if @taiwan_mobile_img.save
			current_user.user_credits.build(name: '下載時空訊息 APP', credits: 50)
			current_user.taiwan_mobile_credits = true
			current_user.save!
			flash[:success] = '成功獲得 台灣大哥大 提供之 50 元購書金！'
			redirect_to :back
		else
			flash[:error] = '上傳失敗，請再試一次'
			render 'sponsors/taiwan_mobile'
		end
	end

	private

	def taiwan_mobile_imgs_params
		params.require(:taiwan_mobile_img).permit(:image_url)
	end
end
