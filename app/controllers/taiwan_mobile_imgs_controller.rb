class TaiwanMobileImgsController < ApplicationController
	before_action :authenticate_user!

	def create
		if current_user.taiwan_mobile_credits
			flash[:error] = '你已經上傳過了唷！'
			return
		end
		@taiwan_mobile_img = current_user.taiwan_mobile_imgs.new(taiwan_mobile_imgs_params)

		if @taiwan_mobile_img.save
			flash[:success] = '成功上傳，我們驗證正確時，您將會獲得 50 元購書金！(大約 1 - 2 小時)'
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
