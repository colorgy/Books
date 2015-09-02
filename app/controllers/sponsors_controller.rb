class SponsorsController < ApplicationController
	before_action :authenticate_user!
	def index

	end

	def colorgy_books

	end

	def taiwan_mobile
		@taiwan_mobile_img = current_user.taiwan_mobile_imgs.new
	end
end
