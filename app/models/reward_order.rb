class RewardOrder < Order
  belongs_to :product, :foreign_key => :buyable_id
  validate :validate_item, on: :create
  delegate :retail_price, :requires_shipping?, to: :product
  
  def contents
    product.name
  end
  
  def product=(p)
    self.buyable_id = p.id
    self.subtotal = p.retail_price
    self.shipping_price = p.shipping_price
    self.point_discount = p.point_discount(account)
    self.sales_tax = p.tax
  end
  
  def kind
    "reward"
  end
  
  def self.cogs
    Money.new(joins(:product).sum(:cost_in_cents).to_i)
  end
  
  protected
  
  def validate_item
    errors.add(:point_discount, :invalid) if point_discount > product.point_discount(account)
  end
  
  def setup_purchase
    account.points -= point_discount
    account.save!
  end
  
  def complete_reset
    account.points += point_discount
    account.save!
  end
  
end