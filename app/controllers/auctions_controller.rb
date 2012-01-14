class AuctionsController < ApplicationController
  set_tab :auctions, :except => :winners
  set_tab :winners, only: :winners
  before_filter :set_affiliate_cookies, only: :show
  caches_action :winners, cache_path: :winners_cache, layout: false

  def index
    @auctions = Auction.homepage(current_user, cookies[:categories]).paginate(page: params[:page], per_page: 16)
    @featured = FeaturedAuction.last
    @winners = Bid.winners(@auctions)
    respond_with @auctions
  end

  def show
    @auction = Auction.find params[:id]
    @product = @auction.product
    @investment = @auction.investment_for current_user
    @winner_investment = @auction.winner_investment
    if logged_out?
      @account = Account.new
    else
      @bot = BidBot.find_or_initialize_by_auction_id_and_account_id(@auction.id, current_user.id)
    end
    force_html @auctions do
      if @auction.finished? then render "static"
      else render "show"
      end
    end
  end

  def winners
    @auctions = Auction.history.in_categories(cookies[:categories]).paginate(page: params[:page], per_page: 15)
    @winners = Bid.winners(@auctions)
    respond_with @auctions
  end
  
  private
  
  def winners_cache_url
    "winners/#{Rails.cache.read('finished', raw: true)}/#{params[:page] || 1}"
  end

end
