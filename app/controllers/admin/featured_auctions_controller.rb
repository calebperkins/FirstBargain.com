class Admin::FeaturedAuctionsController < Admin::AdminController

  def index
    redirect_to [:admin, :auctions]
  end
  
  def show
    @featured = FeaturedAuction.find params[:id]
    @auction = Auction.find(@featured.auction_id)
  end
  
  def edit
    @featured = FeaturedAuction.find params[:id]
  end
  
  def new
    unless params[:auction_id] then
      redirect_to [:admin, :auctions]
    else
      @auction = Auction.find(params[:auction_id])
      @featured = FeaturedAuction.new
    end
  end

  def create
    @featured = FeaturedAuction.new(params[:featured_auction])
    @featured[:auction_id]=(params[:featured_auction][:auction_id]).to_i
    if @featured.save then redirect_to [:admin, @featured], notice: 'Featured auction was successfully created.'
    else
      @auction = Auction.find(params[:featured_auction][:auction_id].to_i)
      render "new"
    end
  end
  
  def update
    @featured = FeaturedAuction.find(params[:id])
    if @featured.update_attributes(params[:auction]) then redirect_to [:admin, @featured], notice: 'Auction was successfully updated.'
    else
      render "edit"
    end
  end
  
  def destroy
    @featured = FeaturedAuction.find params[:id]
    @featured.destroy
    redirect_to admin_auctions_url, notice: 'Auction deleted.'
  end
  
end