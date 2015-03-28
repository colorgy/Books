class Users::MyAccountController < ApplicationController
  before_action :authenticate_user!, except: [:invoice_subsume_confirm]
  skip_before_filter :verify_authenticity_token, only: [:invoice_subsume_confirm]

  def show
    @user = current_user
  end

  def invoice_subsume
    @user = current_user
    @user.invoice_subsume_token = SecureRandom.hex(32)
    @user.invoice_subsume_token_created_at = Time.now
    @user.save!
    @company_tax_id = ENV['COMPANY_TAX_ID']
    @invoice_subsume_url = ENV['INVOICE_SUBSUME_URL']
    @invoice_carrier_code = ENV['INVOICE_CARRIER_CODE']
  end

  def invoice_subsume_confirm
    @user = User.find_by(sid: Base64.decode64(params[:card_no1]), uuid: Base64.decode64(params[:card_no2]))
    if @user && @user.invoice_subsume_token_created_at > 10.minutes.ago && @user.invoice_subsume_token == params[:token]
      render text: 'Y'
    else
      render text: 'N'
    end
  end
end
