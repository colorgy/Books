class PagesController < ApplicationController
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

  def sorry_but_forbidden
    redirect_to root_path if current_user
  end
end

