class PagesController < ApplicationController
  before_filter :sso_off!

  def index

  end

  def flow
    redirect_to flow_buy_path
  end

  def shopping_flow_buy

  end

  def shopping_flow_mainchew

  end

  def shopping_flow_deliver

  end

  def faq

  end

  def not_open_for_orders

  end

  def guide

  end

  def payments

  end

  def sorry_but_forbidden
    redirect_to root_path if current_user && current_user.organization_code
  end
end

