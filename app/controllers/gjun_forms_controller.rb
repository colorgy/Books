class GjunFormsController < ApplicationController
	before_action :authenticate_user!

	def new
		@gjun_form = current_user.gjun_forms.new
	end

  def create
  	return if current_user.gjun_credits
    @gjun_form = current_user.gjun_forms.new(gjun_forms_params)

    if @gjun_form.save
			current_user.user_credits.build(name: '巨匠電腦獎助學生計畫', credits: 50)
			current_user.gjun_credits = true
			current_user.save!
			flash[:success] = '成功獲得 巨匠電腦 提供之 60 元購書金！'
			redirect_to sponsors_gjun_path
    else
    	flash[:success] = '提交失敗'
      redirect_to sponsors_gjun_path
    end
  end

  private

  def gjun_forms_params
    params.require(:gjun_form).permit(:user_id, :if_heard_gjun, :mobile_phone_number)
  end
end
