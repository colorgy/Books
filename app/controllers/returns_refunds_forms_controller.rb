class ReturnsRefundsFormsController < ApplicationController
	before_action :authenticate_user!

	def index
		@returns_refunds_forms = current_user.returns_refunds_forms.all
	end

  def show
		if current_user.id != 4 && current_user.id != 5
	    @returns_refunds_form = current_user.returns_refunds_forms.find(params[:id])
		else
			@returns_refunds_form = ReturnsRefundsForm.find(params[:id])
		end
  end

	def new
		@returns_refunds_form = current_user.returns_refunds_forms.new
    @orders = current_user.orders.has_paid
	end

	def create
    @returns_refunds_form = current_user.returns_refunds_forms.new(returns_refunds_forms_params)

    if @returns_refunds_form.save
			flash[:success] = '成功提交退換書要求，我們會在 2-3 個工作天內回覆您！'
			redirect_to returns_refunds_form_path(@returns_refunds_form)
    else
    	flash[:success] = '提交失敗，請再試一次'
      render 'new'
    end
	end

	def admin
		@returns_refunds_forms = ReturnsRefundsForm.all
	end

	private

	def returns_refunds_forms_params
		params.require(:returns_refunds_form).permit(:if_delivered, :bill_uuid, :account_bank_code, :account_number, :reason, :image_url, :status, :user_id, :condition, :phone_number)
	end
end
