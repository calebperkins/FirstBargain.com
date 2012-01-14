class Auction < ActiveRecord::Base

  money :price_increment
  money :going_price
  money :retail_price
  attr_accessible :product_id, :ending_at, :price_increment, :hot, :is_buy_now, :timer_reset, :beginner
  after_create :set_watchers

  belongs_to :product, inverse_of: :auctions
  belongs_to :account, inverse_of: :auctions
  belongs_to :investment, inverse_of: :auction
  has_many :bids, inverse_of: :auction, :dependent => :destroy
  has_many :investments, inverse_of: :auction, :dependent => :destroy
  has_many :bid_bots, inverse_of: :auction, :dependent => :destroy
  has_one :featured_auction

  scope :active, -> { where("auctions.ending_at > ?", Time.now) }
  scope :inactive, -> { where("auctions.ending_at <= ?", Time.now) }
  scope :ascending, order('auctions.ending_at ASC')
  scope :descending, order('auctions.ending_at DESC')
  scope :ending_soonest, -> {active.ascending}
  scope :latest_ended, -> {inactive.descending}
  scope :hot, where(:hot => true)
  scope :nonredeemed, where(redeemed: false)
  scope :nonbeginner, where(beginner: false)

  scope :detailed, includes(:product)
  scope :upcoming, -> { hot.where('auctions.ending_at > ?', 1.day.from_now.beginning_of_day).ascending }
  scope :finished_this_month, -> {t = Time.current; where(:ending_at => t.beginning_of_month..t).ascending}
  scope :finished_in_last_24_hours, -> {t = Time.current; where(:ending_at => (t - 1.days)..t).ascending}
  scope :history, -> {where(:ending_at => 3.days.ago..Time.now).nonbeginner.descending.includes(:product, :investment)}

  validates :product_id, :ending_at, :retail_price, :presence => true
  validates :redeemed, :hot, :is_buy_now, :inclusion => [true, false]
  validates :price_increment, numericality: {:greater_than => 0}
  validates :going_price, numericality: {greater_than_or_equal_to: 0}
  validate :in_future, on: :create

  def self.expire_redis_job_cache_for_last_24_hours
    Auction.finished_in_last_24_hours.each do |a|
      a.expire_job_cache
    end
  end

  def self.buynowables
    where(is_buy_now: true).where("auctions.ending_at > ?", Time.current - Rails.configuration.buy_now_expiration)
  end

  def self.winnables
    t = Time.current
    t0 = t - Rails.configuration.won_auction_expiration
    where(ending_at: t0..t)
  end

  def self.widgety(w_c, a_c)
    w_c = w_c.split("-")
    a_c = a_c.split("-")
    active.detailed.where("products.category_id" => w_c + a_c).order("products.widget_worthy DESC", "auctions.ending_at ASC").limit(5)
  end

  def recent_bids
    @recent_bids ||= bids.recent.to_a
  end

  def self.current_or_previous
    ending_soonest.first or latest_ended.first
  end

  # Filter beginner auctions
  def self.for_user(u)
    if u && u.beginner? then scoped
    else nonbeginner
    end
  end

  def self.in_categories(c)
    if c.present?
      d = if c.is_a?(String) then c.split("-") # don't use respond_to?
      else c
      end
      detailed.where("products.category_id" => d)
    else scoped
    end
  end

  def product_id=(pid)
    self[:product_id] = pid
    self.retail_price = product.retail_price
  end

  def active?
    !finished
  end

  def winning_bid
    recent_bids.first
  end

  def username(cache = nil)
    if cache then cache[id].try(:username) || "none"
    else winning_bid.try(:username) || "none"
    end
  end

  def self.homepage(user, categories)
    a = hot.latest_ended.limit(1)
    a + for_user(user).active.order('hot DESC, ending_at ASC').in_categories(categories)
  end

  def ending_in=(t)
    self.ending_at = t.from_now
  end

  def won_by?(user)
    user && user.id == account_id && finished?
  end

  def redemption_expired?
    (ending_at + Rails.configuration.won_auction_expiration).past?
  end

  def bids_count
    going_price.cents/price_increment.cents
  end

  def total_buy_now_price(u)
    product.shipping_price + buy_now_price(u)
  end

  def total_won_price
    product.shipping_price + going_price
  end

  def total_winner_price
    going_price + winner_investment.amount
  end

  def can_buy_now?(user)
    is_buy_now and not won_by?(user) and (ending_at + Rails.configuration.buy_now_expiration).future? and not bought_by?(user)
  end

  # Optimize me
  def winner_investment(cache = nil)
    @w ||= account_id ? investment : Investment.new
    #@w ||= if cache then cache[id] || Investment.new
    #else winning_bid.present? ? winning_bid.investment : Investment.new
    #end
  end

  def investment_for(user)
    @i ||= user ? Investment.find_or_initialize_by_account_id_and_auction_id(user.id, id) : Investment.new
  end

  def bought_by?(user)
    investment_for(user).expired
  end

  # MSRP - (# of bids placed on THIS auction * price of bids)
  def buy_now_price(user)
    return retail_price unless user
    inv = investment_for user
    return retail_price if inv.expired
    [retail_price - inv.amount, 0.to_money].max
  end

  def serializable_hash(cache = nil)
    record = {:id => id, :p => going_price.to_f, :u => username(cache), :e => ending_at.to_i}
    record[:w] = winner_investment.serializable_hash
    record[:wp] = total_winner_price.to_f
    record[:done] = finished?
    record
  end

  def winner_savings_ratio
    1 - total_winner_price.to_f/retail_price.to_f
  end

  def as_product(request)
    data = serializable_hash
    data[:name] = product.name
    data[:retail_price] = retail_price.to_f
    data[:picture] = "#{request.protocol}#{request.host_with_port}#{product.main_picture.url(:index)}"
    # Get previous auction
    a2 = Auction.latest_ended.where(:product_id => product_id).first
    if a2
      data[:prev_winner] = a2.username
      data[:prev_price] = a2.total_winner_price.to_f
      data[:prev_savings] = "#{[(a2.winner_savings_ratio*100).floor.round, 0].max}%"
    end
    data
  end

  def as_summary(winners_cache = nil, investment_cache = nil)
    data = serializable_hash(winners_cache)
    data[:investment] = investment_cache[id].try(:serializable_hash) if investment_cache
    data
  end

  def self.summaries(user, ids)
    auctions = Auction.includes(:investment).find(ids)
    winners = Bid.winners(auctions)
    investments = Investment.by_auction(ids, user)
    hash = {}
    if user
      hash[:account] = user.poller_hash
    end
    hash[:auctions] = auctions.map! {|r| r.as_summary(winners, investments)}
    hash
  end

  def as_detailed(u)
    data = serializable_hash
    if u
      i = investments.find_by_account_id(u.id)
      data[:investment] = i.serializable_hash if i
      bot = bid_bots.find_by_account_id(u.id)
      data[:bot] = bot.bids_left if bot
      data[:account] = u.poller_hash
    end
    data[:bids] = recent_bids.each_with_index.map do |b, i|
      b.serializable_hash(going_price - price_increment * i)
    end
    data[:n] = bids_count
    data
  end

  def to_param
    "#{id}-#{product.name.parameterize}"
  end

  def <=>(a)
    ending_at <=> a.ending_at
  end

  def expensive?
    retail_price >= Rails.configuration.price_threshold
  end

  def cache_key
    "auctions/#{id}-#{going_price_in_cents}-#{finished}"
  end

  def expire_job_cache
    $redis.expire("auction_#{id}_job_ids", 0)
  end

  private

  # Bid bot and email winners jobs
  def set_watchers
    Stalker.enqueue("emails.won_auction", {id: id}, {delay: (ending_at - Time.now).round + 30})
    BidBot.enqueue(self)
  end

  def in_future
    errors.add(:ending_at, :past) if ending_at.past?
  end

end
