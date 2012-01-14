class OrdersController < ApplicationController
  before_filter :require_user
  before_filter :require_order, only: [:paypal, :create]
  set_tab :orders, :sidebar
  ssl_exceptions
  cache_sweeper :account_sweeper, only: :create

  def index
    @orders = current_user.orders.order('orders.id DESC')
    force_html @orders do
      render :layout => 'accounts'
    end
  end

  def new
    @order = factory(params, false)
    respond_with @order
  end

  def confirm
    session[:order] = params[:order]
    factory params[:order]
    force_html @order do
      if @order.invalid? && @order.is_a?(BidOrder) then render('bid_packs/new', layout: 'application')
      elsif @order.invalid? then render 'new'
      elsif @order.paypal? then redirect_to @order.paypal_url(paypal_orders_url(secure: true), root_url)
      else redirect_to @order.ccbill_url # render "confirm"
      end
    end
  end

  def create
    factory session[:order]
    session.delete :order
    if @order.save
      flash[:order_id] = @order.id
      @order.process_paypal_purchase!
    end
  end

  def paypal
    session[:order][:express_token] = params[:token]
    factory session[:order]
    session[:order] = @order.to_user_session
    respond_with @order
  end

  def success
    @order = Order.find(flash[:order_id])
    if @order.is_a?(BidOrder) and not @order.account.bids_purchased
      session[:bidpopup] = 1
      @order.account.update_attribute(:bids_purchased, true)
    end
    @msg = @order.transactions.first.message
    respond_with @order
  end

  def failure
    success # the only difference is the template loaded
  end

  private

  def require_order
    redirect_to root_url, alert: t("flash.session.expired_order") unless session[:order]
  end
  
  def factory(source, set_attr = true)
    @order = Order.factory(source, current_user, request.remote_ip, set_attr)
  end

end
