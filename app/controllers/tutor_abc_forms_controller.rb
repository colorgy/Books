class TutorAbcFormsController < ApplicationController
	before_action :authenticate_user!

	def new
		@tutor_abc_form = current_user.tutor_abc_forms.new
	end

  def create
  	return if current_user.tutorabc_check_credits
    @tutor_abc_form = current_user.tutor_abc_forms.new(tutor_abc_forms_params)

    if @tutor_abc_form.save
			current_user.user_credits.build(name: 'TutorABC 獎助學生計畫', credits: 50)
			current_user.tutorabc_check_credits = true
			current_user.save!
			flash[:success] = '成功獲得 tutorABC 提供之 50 元購書金！'
			redirect_to sponsors_tutorABC_path
    else
    	flash[:success] = '提交失敗'
      redirect_to sponsors_tutorABC_path
    end
  end

  private

  def tutor_abc_forms_params
    params.require(:tutor_abc_form).permit(:user_id, :if_heard_tutor_abc, :mobile_phone_number)
  end
end
