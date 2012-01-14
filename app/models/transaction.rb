class Transaction < ActiveRecord::Base
  money :amount
  belongs_to :order, inverse_of: :transactions
  serialize :params
  
  validates :order_id, :amount, :message, :presence => true
  validates :success, :inclusion => [true, false]
  validates :action, :inclusion => %w(purchase refund)
  
  def response=(response)
    self.success       = response.success?
    self.authorization = response.authorization
    self.message       = response.message
    self.params        = response.params
  rescue ActiveMerchant::ActiveMerchantError => e
    self.success       = false
    self.authorization = nil
    self.message       = e.message
    self.params        = {}
  end
  
  def processor
    params["transaction_type"] == "express-checkout" ? "PayPal" : "Authorize.net"
  end

end
