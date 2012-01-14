# Bids on an auction on a user's behalf. Every few seconds before an auction ends, the system will query all registered bots for the auction and update one of them.
class BidBot < ActiveRecord::Base
  money :bid_from
  belongs_to :auction, inverse_of: :bid_bots
  belongs_to :account
  
  #validates :auction_id, :uniqueness => {:scope => :account_id}
  validates :bid_from, numericality: {greater_than_or_equal_to: 0}
  validates :bids_left, numericality: {greater_than_or_equal_to: 0}, on: :update
  validate :number_of_bids, on: :create
  validate :active_bots, on: :create
  
  attr_protected :account_id, :auction_id
  
  after_create :create_investment
  after_destroy :remove_investment_if_unused
  
  
  def self.enqueue(a)
    unless a.finished?
      Stalker.enqueue("bid_bot", {id: a.id, redis_job_id: $redis.incr("last_bid_bot_job_id")}, {delay: bidbot_bid_delay(a)}) 
      $redis.sadd("auction_#{a.id}_job_ids", $redis.get("last_bid_bot_job_id"))
    end
  end
  
  def bid!
    b = Bid.new(:account => account, :auction => auction)
    b.botted = true
    decrement(:bids_left).save if b.save # TODO: transactions
    b.persisted?
  end
  
  private
  
  #Returns a delay time for stalker based on a probability distribution
  def self.bidbot_bid_delay(a)
    r = (rand * 100).floor
    case(r)
    when 0..14 then offset_seconds = (4 + r)
    when 15..24 then offset_seconds = 3
    when 25..49 then offset_seconds = 2
    when 50..99 then offset_seconds = 1
    end
    Rails.logger.debug "Rand #{offset_seconds}"
    calculate_delay_from_offset(a, offset_seconds)
  end
  
  def self.calculate_delay_from_offset(a, offset)
    ((a.ending_at - Time.now).floor - offset)
  end
  
  
  # Get an okay bound on good bots for an auction. We still might need to try some bots to see if they can bid.
  # TODO: caching. Also, move this into Auction model?
  # If you update this query be sure the appropriate database indexes are in place
  def self.pool(a)
    bots = a.reload.bid_bots
    bots = bots.where("bid_bots.account_id <> ?", a.account_id) if a.account_id?
    bots = bots.where("bid_bots.bids_left > ?", 0).where("bid_bots.bid_from_in_cents <= ?",  a.going_price.cents)
    bots.shuffle! # bots.order(configurations[Rails.env]['adapter'] == "sqlite3" ? "random()" : "rand()")
  end
  
  def number_of_bids
    errors.add(:bids_left, :not_in_range) unless (3..50).include?(bids_left)
    errors.add(:bids_left, :need_more_bids) if account.total_bids < bids_left.to_i
    b = Bid.new(:account => account, :auction => auction)
    errors.add(:base, b.errors.full_messages.first) if b.invalid?
  end
  
  # If this bot is destroyed but not used yet, destroy the investment to clear an active auctions site
  def remove_investment_if_unused
    i = auction.investment_for(account)
    i.destroy if i.bids_used.zero?
  end
  
  # Create a placeholder investment to take up an active auction slot
  def create_investment
    i = auction.investment_for(account)
    i.save! if i.new_record?
  end
  
  def active_bots
    errors.add(:base, :active_bot_limit) if account.active_bots.size >= 1
  end
  
end
