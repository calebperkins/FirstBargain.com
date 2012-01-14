class Bid < ActiveRecord::Base

  belongs_to :account, inverse_of: :bids
  belongs_to :auction, inverse_of: :bids

  validates :account_id, :auction_id, :username, presence: true
  validates :paid, inclusion: [true, false]
  validate :goodness, on: :create

  attr_accessible :auction_id, :auction, :account, :account_id

  scope :recent, order('bids.id DESC').limit(10)

  after_create :expire_redis_bidbot_set, :update_account, :update_investment, :update_auction, :enqueue_bid_bot_job
  after_commit :increment_cache

  # Bottleneck. Refer to "max n per group" problem, or
  # http://www.xaprb.com/blog/2006/12/07/how-to-select-the-firstleastmax-row-per-group-in-sql/
  def self.winners(auctions)
    auction_ids = auctions.map {|a| a.id}
    query = "select * from (select auction_id, max(id) as maxid from bids where auction_id in(?) group by auction_id) as x inner join bids as b on b.auction_id = x.auction_id and b.id = x.maxid"
    records = find_by_sql [query, auction_ids]
    records.index_by {|r| r.auction_id}
    # Old, slower:
    # records = where(:auction_id => auction_ids).where("id = (select max(id) from bids as b where b.auction_id = bids.auction_id)")
  end

  def serializable_hash(price)
    {u: username, t: created_at.to_s(:bid), p: price.to_f}
  end

  def price(counter)
    auction.going_price - auction.price_increment * counter
  end

  def investment
    @investment ||= Investment.find_or_initialize_by_account_id_and_auction_id(account_id, auction_id)
  end

  def account=(u)
    self.account_id = u.id
    self.username = u.username
    self.paid = u.bonuses < 1
  end

  private

  def goodness
    error = first_time_bidding if investment.new_record?
    error ||= if investment.expired? then :buy_now_used
    elsif auction.ending_at.past? then :auction_ended
    elsif not account.has_bids? then :need_more_bids
    elsif account_id == auction.recent_bids.first.try(:account_id) then :bid_twice
    end
    errors.add(:base, error) if error.present?
    errors.add(:investment, :overinvested) if paid && auction.is_buy_now && overinvested?
  end

  def first_time_bidding
    t = Time.current
    wins = account.wins_this_month.to_a
    y = [Rails.configuration.monthly_win_limit - wins.size, 0].max
    x = [Rails.configuration.daily_win_limit - wins.count {|a| a.ending_at > t.beginning_of_day && a.ending_at < t}, 0].max # (t.beginning_of_day..t).include?(a.ending_at) no good, bug?
    z = account.active_auctions.to_a
    if y.zero? then :monthly_win_limit_reached
    elsif x.zero? then :daily_win_limit_reached
    elsif y <= z.size then :monthly_active_auctions_limit
    elsif x <= z.size then :daily_active_auctions_limit
    elsif auction.expensive? && (wins+z).any? {|a| a.product_id == auction.product_id} then :item_too_expensive
    elsif auction.beginner && z.any? {|a| a.beginner?} then :beginner_limit
    elsif auction.beginner && !account.beginner? then :not_beginner
    end
  end

  def overinvested?
    auction.going_price + investment.amount + Rails.configuration.bid_unit_price > auction.retail_price
  end

  # Update the time, investment, and user id as atomically as possible.
  def update_auction
    x = Time.current + auction.timer_reset.seconds
    time = auction.ending_at < x ? x : auction.ending_at
    updates = ["going_price_in_cents = going_price_in_cents + price_increment_in_cents, account_id = ?, investment_id = ?, ending_at = ?", account.id, investment.id, time]
    Auction.update_all(updates, id: auction.id)
  end

  def update_account
    account.decrement(paid ? :credits : :bonuses).save!
  end

  def update_investment
    if paid then investment.increment(:credits_used).increment(:amount_in_cents, Rails.configuration.bid_unit_price.cents)
    else investment.increment(:bonuses_used)
    end.save!
  end

  def increment_cache
    Rails.cache.increment("bids")
  end

  def expire_redis_bidbot_set
    $redis.expire("auction_#{auction.id}_job_ids", 0)
    true
  end

  def enqueue_bid_bot_job
    BidBot.enqueue(auction.reload)
    true
  end

end
