# TODO: make this RESTful
class BidBotsController < ApplicationController
  before_filter :require_user

  def create
    @auction = Auction.find(params[:auction_id])
    @bot = BidBot.find_or_initialize_by_account_id_and_auction_id(current_user.id, @auction.id)
    if @bot.new_record?
      @bot.attributes = params[:bid_bot]
      @bot.save
    else
      @bot.destroy
    end
  end

end
