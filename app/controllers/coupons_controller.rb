class CouponsController < ApplicationController
  before_filter :require_user
  layout 'accounts'
  set_tab :coupons, :sidebar
  
  def new
    @c = CouponUse.new
    respond_with @c
  end
  
  def create
    @c = CouponUse.new params[:coupon_use]
    @c.account = current_user
    flash.notice = t("flash.coupons.created", count: @c.bonuses) if @c.save
    respond_with @c, location: account_url
  end
  
end
