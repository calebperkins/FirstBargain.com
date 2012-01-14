class BidPacksController < ApplicationController
  set_tab :bids
  ssl_exceptions
  before_filter :require_user
  
  def new
    @order = BidOrder.new
    force_html @order do
      if current_user.has_purchased? then render "new"
      else render "first"
      end
    end
  end

end
