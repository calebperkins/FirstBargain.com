# Where everything happens
class ApplicationController < ActionController::Base
  include SslRequirement
  protect_from_forgery
  respond_to :html
  helper_method :current_user, :logged_in?, :logged_out?
  before_filter :require_vip if Rails.env.staging?
  before_filter :set_utm_cookies, if: -> {params[:utm_source].present?}
  rescue_from ActionController::InvalidAuthenticityToken, with: :rescue_invalid_token

  private
  
  def set_affiliate_cookies
    [:affiliate, :categories, :affiliate_url].each do |sym|
      cookies[sym] = {value: params[sym], expires: 1.week.from_now} if params[sym].present?
    end
  end

  def set_utm_cookies    
    [:utm_source, :utm_medium, :utm_campaign, :utm_term, :utm_content].each do |sym|
      cookies[sym] = {value: params[sym], expires: 1.week.from_now} if params[sym].present?
    end
  end

  def rescue_invalid_token
    store_location
    redirect_to new_session_url, alert: t("flash.session.expired")
  end

	def current_user_session
	  return @current_user_session if defined? @current_user_session
	  @current_user_session = AccountSession.find
	end

	def current_user
	  return @current_user if defined? @current_user
	  @current_user = current_user_session.try :record
	end
	
	def logged_in?
	  !!current_user
  end
  
  def logged_out?
    !current_user
  end

	def vip
	  return @vip if defined? @vip
	  @vip = vip_session.try :record
  end

  def vip_session
    return @vip_session if defined? @vip_session
    @vip_session = ViewerSession.find
  end

	def require_user
	  if logged_out?
      store_location
      redirect_to new_session_url
	  end
	end

	def require_no_user
	  if logged_in?
      store_location
      redirect_to account_url, alert: t("flash.session.must_be_logged_out")
	  end
	end

	def store_location
    session[:return_to] = request.get? ? request.fullpath : request.referer
	end

	def redirect_back_or(default, options = {})
    path = (session[:return_to] || default)
    session.delete :return_to
    redirect_to path, options
	end

	def require_vip
	  redirect_to splash_url unless vip
  end
  
  # We need this because sometimes the http-accept on browsers is screwed up and they try requesting XML or something
  def force_html(obj, options = {})
    respond_with obj, options do |format|
      format.html do
        yield
      end
    end
  end

end
