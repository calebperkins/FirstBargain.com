class Admin::AuctionsController < Admin::AdminController

  def index
    respond_to do |wants|
      wants.html do
        @featured = FeaturedAuction.last
        @active = Auction.active.descending.includes(:product).paginate :page => params[:active]
        @finished = Auction.latest_ended.includes(:product).paginate :page => params[:finished]
      end
      wants.xml {render :xml => Auction.latest_ended.includes(:product)}
    end
  end

  def show
    @auction = Auction.detailed.find params[:id]
    @bids = @auction.bids.includes(:account)
  end

  def new
	  @products = Product.where(discontinued: false).order('name ASC')
    @auction = Auction.new
  end

  def edit
	  @products = Product.order('name ASC')
    @auction = Auction.find(params[:id])
  end

  def create
    @auction = Auction.new(params[:auction])
    if @auction.save then redirect_to [:admin, @auction], notice: 'Auction was successfully created.'
    else
      @products = Product.order('name ASC')
      render "new"
    end
  end

  def update
    @auction = Auction.find(params[:id])
	  if @auction.update_attributes(params[:auction]) then redirect_to [:admin, @auction], notice: 'Auction was successfully updated.'
	  else
	    @products = Product.order('name ASC')
	    render "edit"
	  end
  end

  def destroy
    @auction = Auction.find(params[:id])
    if @auction.bids.empty? then
      @auction.destroy
	    redirect_to admin_auctions_url, notice: "Auction deleted."
    else redirect_to admin_auctions_url, alert: "Auction has bids. Cannot delete."
    end
  end

end
