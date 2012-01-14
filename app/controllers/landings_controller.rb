class LandingsController < ApplicationController
  def show
    @auction = Auction.where(:product_id => params[:id]).current_or_previous
    if @auction.present?
      @product = @auction.product
      @winner_investment = @auction.winner_investment
      @investment = @auction.investment_for current_user
      @account = current_user ? current_user : Account.new
      force_html @auction do
        render(@auction.active? ? :active : :finished)
      end
    else redirect_to root_url
    end
  end
  
  def promo
    reject = [1,12,13,14,15,28,29]
    cats = (1..40).reject {|c| (reject.include? c)}
    @auctions = Auction.homepage(current_user, cats)[0..7]
    @account = Account.new
    force_html @auctions do
      render "promo", :layout => nil
    end
  end
  
  def category   
    @auction = Auction.in_categories(params[:id]).current_or_previous
    if @auction.present?
      @product = @auction.product
      @winner_investment = @auction.winner_investment
      @investment = @auction.investment_for current_user
      @account = current_user ? current_user : Account.new
      @upcoming = Auction.ending_soonest.includes(:product).limit(4)
      @ended = Auction.inactive.order("products.widget_worthy DESC", "auctions.ending_at ASC").includes(:product).limit(4)
      force_html @auction do
        render :category
      end
    else redirect_to root_url
    end
  end

end
