class SponsorsController < ApplicationController
	def index

	end

	def colorgy_books
		if current_user.blank?
			flash[:error] = '請先登入'
			redirect_to sponsors_path
		end
	end

	def taiwan_mobile
		if current_user.blank?
			flash[:error] = '請先登入'
			redirect_to sponsors_path
		else
			@taiwan_mobile_img = current_user.taiwan_mobile_imgs.new
		end
	end

	def taiwan_mobile_admin
		if current_user.blank?
			redirect_to sponsors_path
		else
			if current_user.id != 4 && current_user.id != 5
				flash[:error] = '你沒有權限進入此頁面'
				redirect_to sponsors_path
			else
				@taiwan_mobile_imgs = TaiwanMobileImg.all
			end
		end
	end

	def tutor_abc
		if current_user.blank?
			flash[:error] = '請先登入'
			redirect_to sponsors_path
		else
			@tutor_abc_form = current_user.tutor_abc_forms.new
		end
	end

	def gjun
		if current_user.blank?
			flash[:error] = '請先登入'
			redirect_to sponsors_path
		else
			@gjun_form = current_user.gjun_forms.new
		end
	end
end
