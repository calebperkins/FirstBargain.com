# An order for an auction a user has won. To be created, it must be nonredeemed and won by that user.
class AuctionOrder < Order

  belongs_to :auction, :foreign_key => :buyable_id
  validate :validate_item, on: :create
  delegate :product, :retail_price, to: :auction

  def contents
    product.name
  end

  def auction=(a)
    self.buyable_id = a.id
    self.subtotal = a.going_price
    self.shipping_price = a.product.shipping_price
    self.point_discount = 0
  end

  def requires_shipping?
    product.requires_shipping
  end

  def bid_pack?
    product.bonuses > 0
  end
  
  def kind
    "auction"
  end
  
  def self.cogs
    Money.new(joins(:auction => :product).sum(:cost_in_cents).to_i)
  end

  protected

  def validate_item
    error = if not auction.won_by?(account) then :did_not_win
    elsif auction.redeemed then :already_redeemed
    elsif auction.redemption_expired? then :expired
    end
    errors.add(:base, error) if error
  end

  def finish_purchase
    account.award(:bonuses, auction.product.bonuses).save!
  end
  
  def complete_reset
    auction.update_attribute(:redeemed, false)
  end
  
  def setup_purchase
    auction.update_attribute(:redeemed, true)
  end

end