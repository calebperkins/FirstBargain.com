class BidsController < ApplicationController
  before_filter :require_user
  respond_to :js
  #respond_to :html, :except => :create

  def create
    @auction = Auction.find params[:auction_id]
    @bid = Bid.create :account => current_user, :auction => @auction
    current_user.decrement(@bid.paid ? :credits : :bonuses) if @bid.persisted? # avoid current_user.reload
    respond_with(@auction, @bid, location: @auction) do |wants|
      wants.js do
        if @bid.errors.empty? then render 'success'
        elsif @bid.errors[:investment].any? then render 'buynow'
        else render 'failure'
        end
      end
      wants.html do
        @bid.errors.empty? ? flash.notice = t("flash.bids.without_xhr") : flash.alert = @bid.errors.full_messages[0]
        redirect_to @auction
      end
    end
  end

end
