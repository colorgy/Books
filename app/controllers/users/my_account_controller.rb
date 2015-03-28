class Users::MyAccountController < ApplicationController
  before_action :authenticate_user!, except: [:invoice_subsume_confirm]
  skip_before_filter :verify_authenticity_token, only: [:invoice_subsume_confirm]

  def show
    @user = current_user
  end

  def invoice_subsume
    @user = current_user
    @company_tax_id = ENV['COMPANY_TAX_ID']
    @invoice_subsume_url = ENV['INVOICE_SUBSUME_URL']
    @invoice_carrier_code = ENV['INVOICE_CARRIER_CODE']
  end

  def invoice_subsume_confirm
    render text: 'Y'
  end
end
