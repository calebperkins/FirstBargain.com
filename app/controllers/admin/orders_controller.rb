class Admin::OrdersController < Admin::AdminController
  
  def index
    @orders = Order.search(params[:type], params[:s]).paginate :page => params[:page]
  end
  
  def show
    @order = Order.includes(:transactions, :account).find params[:id]
  end
  
  def edit
    @order = Order.find params[:id]
  end
  
  def ship
    @order = Order.find params[:id]
    @order.confirmation = params[:order][:confirmation]
    @order.tracking_id = params[:order][:tracking_id]
    @order.shipping_company = params[:order][:shipping_company]
    @order.ship!
    redirect_to admin_orders_url, notice: "Shipped order #{@order.id}."
  end
  
  def void
    @order = Order.find params[:id]
    @order.void!
    redirect_to admin_orders_url, notice: "Voided order #{@order.id}."
  end
  
  def approve
    @order = Order.find params[:id]
    @order.capture!
    redirect_to admin_orders_url, notice: "Approved order #{@order.id}"
  end
  
  def refund
    @order = Order.find params[:id]
    @order.refund!
    redirect_to admin_orders_url, alert: "Refunded order #{@order.id}. Remember to adjust their bids as needed!"
  end
  
end
