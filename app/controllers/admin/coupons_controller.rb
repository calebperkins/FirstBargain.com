class Admin::CouponsController < Admin::AdminController
  
  def index
    @coupons = Coupon.all
  end
  
  def new
    @c = Coupon.new
  end
  
  def create
    @c = Coupon.new params[:coupon]
    @c.save
    respond_with @c, location: admin_coupons_url
  end
  
end
