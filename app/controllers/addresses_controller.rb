class AddressesController < ApplicationController
  before_filter :require_user
  layout 'accounts'
  set_tab :addresses, :sidebar

  def index
    @addresses = current_user.addresses
  end
  
  def new
    @address = Address.new
  end
  
  def create
    @address = Address.new params[:address]
    @address.account = current_user
    if @address.save then redirect_to addresses_url, notice: t("flash.addresses.created")
    else render "new"
    end
  end
  
  def destroy
    @address = Address.find(params[:id])
    @address.destroy
    redirect_to addresses_url, notice: t("flash.addresses.deleted")
  end

end
