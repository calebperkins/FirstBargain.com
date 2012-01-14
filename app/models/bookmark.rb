# A bookmarked auction on the user's watchlist.
class Bookmark < ActiveRecord::Base

  belongs_to :account, inverse_of: :bookmarks
  belongs_to :auction
  
  validates :auction_id, :presence => true, :uniqueness => {:scope => :account_id}
  validates :account_id, :presence => true
  
end
