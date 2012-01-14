class FeaturedAuction < ActiveRecord::Base
  attr_accessible :name, :description, :image_url  
  belongs_to :auction
  validates :auction_id, :name, presence: true
end
