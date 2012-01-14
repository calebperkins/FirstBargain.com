class AccountsController < ApplicationController
  ssl_required :new, :create, :edit, :update, :welcome
  before_filter :require_user, only: [:show, :edit, :update, :welcome]
  before_filter :require_no_user, only: [:new, :create]
  set_tab :register, only: [:new, :create]
  set_tab :overview, :sidebar, only: :show
  set_tab :settings, :sidebar, only: [:edit, :update]

  def new
    cookies[:referral] = {value: params[:u], expires: 1.week.from_now} if params[:u].present?
    @account = Account.new
    force_html @account do
      render :layout => 'application'
    end
  end

  def create
    @account = Account.new params[:account]
    @account.registration_ip = request.remote_ip
    [:affiliate, :referral, :utm_medium, :utm_source, :utm_campaign, :utm_term, :utm_content].each do |sym|
      @account.public_send("#{sym}=", cookies[sym])
    end
    force_html @account do
      if @account.save
        cookies.delete :referral
        session[:welcome] = true
        redirect_to welcome_account_url, notice: t("flash.account.created")
      else render "create", :layout => 'application'
      end
    end
  rescue ActiveRecord::RecordNotUnique # database hicupped, account was made
    session[:welcome] = true
    redirect_to welcome_account_url
  rescue ActionController::InvalidAuthenticityToken
    Rails.logger.warn "InvalidAuthenticityToken on registration page."
    redirect_to new_account_url, alert: t("flash.session.expired_on_registration")
  end

  def show
    @winnings = current_user.winnings
    @wins = current_user.wins_this_month.includes(:product)
    @buynows = current_user.buynows.paginate(page: params[:page], per_page: 10)
    respond_with current_user
  end

  def edit
    respond_with current_user
  end

  def update
    x = current_user.username
    if current_user.update_attributes(params[:account]) then flash.notice = t("flash.account.updated")
    else current_user.username = x
    end
    respond_with(current_user, location: account_url)
  end

  def welcome
    if session[:welcome]
      @order = BidOrder.new
      session.delete :welcome
      cookies[:beginner] = 1
      render :layout => 'application'
    else redirect_to bids_url(:secure => true)
    end
  end

end
