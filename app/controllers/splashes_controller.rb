class SplashesController < ApplicationController
  skip_before_filter :require_vip
  layout nil
#  ssl_exceptions
  
  def show
    @a = ViewerSession.new
    respond_with @a
  end
  
  def create
    @a = ViewerSession.new params[:viewer_session]
    force_html @a do
      if @a.save then redirect_to auctions_url
      else render "show"
      end 
    end
  end
  
end
