class ActivationsController < ApplicationController
  before_filter :require_user, only: :create
  
  def new
    @account = Account.find_by_single_access_token params[:code]
    if not @account then flash.alert = t("flash.activations.account_not_found")
    elsif @account.verified? then flash.alert = t("flash.activations.already_verified")
    else
      @account.activate
      flash.notice = t("flash.activations.activated")
    end
    redirect_to root_url
  end
  
  def create
    if current_user.verified? then redirect_to root_url, alert: t("flash.activations.already_verified")
    else
      current_user.deliver_activation_instructions
      redirect_to account_path, notice: t("flash.activations.created")
    end
  end

end
