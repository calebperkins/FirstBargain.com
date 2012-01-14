class BookmarksController < ApplicationController
	before_filter :require_user
	layout "accounts"
	set_tab :watchlist, :sidebar
	respond_to :js, only: :destroy

	def index
	  @watchlist = current_user.watched_auctions.order 'bookmarks.created_at DESC'
	  respond_with @watchlist
  end

	def create
	  @auction = Auction.find params[:auction_id]
	  @bookmark = Bookmark.find_or_create_by_account_id_and_auction_id current_user.id, @auction.id
	  respond_with @bookmark, location: bookmarks_url
	end

	def destroy
	  @auction = Auction.find params[:id]
		@bookmark = Bookmark.find_by_auction_id_and_account_id! @auction.id, current_user.id
		@bookmark.destroy
		respond_with @bookmark, location: bookmarks_url
	end
end
