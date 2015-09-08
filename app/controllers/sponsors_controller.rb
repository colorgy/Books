class SponsorsController < ApplicationController
	before_action :authenticate_user!
	def index

	end

	def colorgy_books

	end

	def taiwan_mobile
		@taiwan_mobile_img = current_user.taiwan_mobile_imgs.new
	end

	def taiwan_mobile_admin
		if current_user.id != 9 || current_user.id != 5
			flash[:error] = '你沒有權限進入此頁面'
			redirect_to sponsors_path
		else
			@taiwan_mobile_imgs = TaiwanMobileImg.all
		end
	end

	def tutor_abc

	end
end
