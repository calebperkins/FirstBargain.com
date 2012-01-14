class BidOrder < Order
  alias_attribute :quantity, :buyable_id
  alias_attribute :retail_price, :subtotal

  validates :quantity, inclusion: {in: [30, 50, 100, 200], message: "is not valid"}, on: :create

  def quantity=(q)
    self.buyable_id = q.to_i
    self.subtotal = Rails.configuration.bid_unit_price * q.to_i
    self.shipping_price = 0
    self.point_discount = 0
  end

  def requires_shipping?
    false
  end
  
  def bid_pack?
    true
  end

  def contents
    "Bid pack (#{quantity})"
  end
  
  def kind
    "bidpack"
  end

  protected

  def finish_purchase
    account.award(:credits, quantity)
    account.points += subtotal
    account.save!
  end

end