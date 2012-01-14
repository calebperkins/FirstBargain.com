# How much a user has spent on an auction, enabling custom buy-now prices.
class Investment < ActiveRecord::Base
  money :amount
  belongs_to :account, inverse_of: :investments
  belongs_to :auction, inverse_of: :investments

  validates :account_id, :auction_id, presence: true
  validates :amount, :credits_used, :bonuses_used, numericality: {greater_than_or_equal_to: 0}
  validates :expired, inclusion: [true, false]

  scope :nonexpired, where(expired: false)
    
  # Expire all buy now prices older than 24 hours
  def self.perform
    nonexpired.where("updated_at <= ?", Rails.configuration.buy_now_expiration.ago).update_all(expired: true)
  end
  
  def self.by_auction(auction_ids, user)
    where(account_id: user.try(:id), auction_id: auction_ids).index_by(&:auction_id)
  end

  def expire!
    self.expired = true
    save!
  end
  
  def unexpire!
    self.expired = false
    save!
  end

  def bids_used
    bonuses_used + credits_used
  end

  def buynow_price
    [auction.retail_price - amount, 0.to_money].max
  end

  def serializable_hash(options = nil)
    {a: amount.to_f, c: credits_used, b: bonuses_used}
  end
  
end
