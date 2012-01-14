class BuyNowOrder < Order
  belongs_to :auction, :foreign_key => :buyable_id
  validate :validate_item, on: :create
  delegate :retail_price, :product, to: :auction
  delegate :requires_shipping?, to: :product

  def contents
    product.name
  end

  def auction=(a)
    self.buyable_id = a.id
    self.subtotal = a.buy_now_price(account)
    self.shipping_price = a.product.shipping_price
    self.point_discount = 0
    self.sales_tax = a.product.tax
  end

  def bid_pack?
    product.bonuses > 0
  end
  
  def kind
    "buynow"
  end
  
  def self.cogs
    Money.new(joins(:auction => :product).sum(:cost_in_cents).to_i)
  end

  protected

  def validate_item
    errors.add(:auction, :invalid) unless auction.can_buy_now?(account)
    #errors.add(:subtotal, "is not correct") if subtotal < auction.buy_now_price(account)
  end

  def finish_purchase
    account.award(:bonuses, auction.product.bonuses).save!
  end

  def setup_purchase
    auction.investment_for(account).expire!
  end

end