class Admin::AdminController < ApplicationController
  
  before_filter :require_admin if Rails.env.production?
  layout 'admin'
  respond_to :html, :js, :xml
  
  private
  
  def require_admin
    redirect_to root_url unless current_user.try :admin?
  end
  
end