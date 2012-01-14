class Account < ActiveRecord::Base

  acts_as_authentic do |c|
    c.validate_email_field false
    c.validates_length_of_login_field_options within: 3..14, if: :username_changed?
    c.validates_format_of_login_field_options with: /\A[a-zA-Z0-9]+$/, if: :username_changed?
  end
  
  belongs_to :parent, class_name: "Account"
  has_many :children, class_name: "Account", foreign_key: "parent_id"
  has_many :bids, inverse_of: :account
  has_many :auctions, inverse_of: :account
  has_many :bookmarks, inverse_of: :account, dependent: :destroy
  has_many :orders, inverse_of: :account
  has_many :investments, inverse_of: :account
  has_many :watched_auctions, through: :bookmarks, source: :auction
  has_many :bid_auctions, through: :investments, source: :auction
  has_many :addresses, inverse_of: :account, dependent: :destroy
  has_many :bid_bots, inverse_of: :account, dependent: :destroy
  
  scope :member_between, ->(from, to) {where(created_at: from..to)}
  
  money :points
  attr_accessor :terms_of_service
  attr_reader :points_increment, :credits_increment, :bonuses_increment
  attr_accessible :username, :email, :password, :password_confirmation, :terms_of_service, :birth_date, :referral, :source, :subscribed
  alias_attribute :affiliate, :source

  validates :email, email: {mx: false}, format: {without: Rails.configuration.banned_domains}, uniqueness: {case_sensitive: false}, if: :email_changed?
  validates :terms_of_service, acceptance: true
  validates :points, :bonuses, :credits, numericality: {greater_than_or_equal_to: 0}
  validate :legal_adult, if: :birth_date_changed?
  validate :limit_username_change, if: :username_changed?
  validate(:check_ip, on: :create) if Rails.env.production?

  after_create :deliver_welcome_and_verification
  after_validation :set_last_change, if: :username_changed?

  SEARCHABLE = %w(username email registration_ip current_login_ip last_login_ip source).map! {|a| "accounts.#{a} LIKE ?"}.freeze
  
  def self.search(q)
    if q.present? then where([SEARCHABLE.join(" OR ")] + SEARCHABLE.map {q})
    else scoped
    end.order('accounts.id DESC')
  end

  # Active auctions being bid on
  def active_auctions
    Auction.active.joins(:investments).where(investments: {account_id: id})
  end
  
  # Bots participating in active auctions
  def active_bots
    bid_bots.joins(:auction).where("auctions.ending_at > ?", Time.now)
  end

  def referral=(a)
    self.parent = self.class.find_by_username(a) if a.present?
  end

  def referral
    parent.username if parent_id?
  end

  def referral_link
    "https://www.firstbargain.com/account/new?u=#{username}"
  end

  def make_first_purchase
    return if has_purchased
    self.has_purchased = true
    parent.award(:bonuses, Rails.configuration.referral_bonus).save! if parent_id
    save!
  end

  def total_bids
    credits + bonuses
  end

  def has_bids?
    total_bids > 0
  end
  
  # How much has the user spent on our site?
  def total_spent
    @spent ||= orders.good.reduce(0.to_money) {|spent, order| spent + order.total_price}
  end
  
  # How much has the user's wins cost us?
  def total_cost
    @value ||= orders.where('type != "BidOrder"').good.reduce(0.to_money) do |value, order|
      value + order.product.cost
    end
  end
  
  def profit_and_loss
    total_spent - total_cost
  end
  
  def poller_hash
    {c: credits, b: bonuses}
  end
  
  def beginner?
    reload.auctions.inactive.blank?
  end
  
  def already_won?(auction)
    wins_this_month.where(product_id: auction.product_id).present?
  end
  
  def wins_left_this_month
    [Rails.configuration.monthly_win_limit - wins_this_month.size, 0].max
  end
  
  def wins_left_today
    [Rails.configuration.daily_win_limit - wins_today.size, 0].max
  end

  def winnings
    auctions.winnables.descending.nonredeemed.detailed
  end

  def wins_this_month
    auctions.finished_this_month
  end

  def wins_this_week
    t = Time.current
    auctions.where(ending_at: (t - 1.week)..t)
  end
  
  def wins_today
    t = Time.current
    auctions.where(ending_at: t.beginning_of_day..t)
  end

  # Keep in sync with Auction::can_buy_now?
  def buynows
    bid_auctions.inactive.where("investments.expired" => false).
    where("auctions.account_id <> ?", id).buynowables.
    detailed.order('investments.updated_at DESC')
  end

  def deliver_password_reset_instructions
    reset_perishable_token!
    Stalker.enqueue("emails.customer", {method: :forgot_password, params: id})
  end

  def admin?
    Rails.configuration.admins.include? id
  end

  def activate
    raise "Account #{id} is already verified" if verified
    toggle(:verified)
    award(:bonuses, Rails.configuration.subscription_bonus) if subscribed?
    save!
  end

  def adjust(a)
    award(:credits, a[:credits_increment])
    award(:bonuses, a[:bonuses_increment])
    self.points += a[:points_increment].to_money
    save
  end

  def deliver_activation_instructions
    Stalker.enqueue("emails.customer", {method: :activation_instructions, params: id})
  end
  
  # Convenience setter to set cumulative bids and normal bids. Use this only when the cumulative counter should be increased too.
  def award(kind, n = 1)
    n = n.to_i
    self[kind] += n
    self["cumulative_#{kind}".to_sym] += n
    self
  end
  
  def self.sync_mailchimp
    g = Gibbon::API.new("7657cdcddee2100d5498b5920f5383a6-us2", cid: "5d4c9b54b1")
    records = g.campaignAbuseReports["data"] + g.campaignMembers(status: "soft")["data"] + g.campaignMembers(status: "hard")["data"]
    records.map! {|r| r["email"]}
    where(email: records).update_all(good_email: false)
    where(email: g.campaignUnsubscribes["data"]).update_all(subscribed: false)
  end
  
  private
  
  def deliver_welcome_and_verification
    Stalker.enqueue("emails.customer", {method: :welcome, params: id})
    deliver_activation_instructions
  end

  def limit_username_change
    errors.add(:username, :limited) if last_username_change && last_username_change > 1.month.ago
  end

  def set_last_change
    self.last_username_change = Time.now
  end

  def check_ip
    if Account.where(registration_ip: registration_ip).present? && Approval.without?(registration_ip)
      logger.warn "REGISTRATION FAILED - (#{username}, #{registration_ip})"
      errors.add(:base, :ip_taken)
    end
  end
  
  def legal_adult
    errors.add(:birth_date) if birth_date > 18.years.ago.to_date
  end

end
