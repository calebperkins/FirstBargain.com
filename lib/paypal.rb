module PayPal
  
  def self.included(klass)
    klass.class_eval do
      private :setup_paypal_options, :express_purchase_options
    end
  end
  
  def process_paypal_purchase!
    response = begin
      Rails.configuration.paypal.purchase total_price.cents, express_purchase_options
    rescue ActiveMerchant::ConnectionError
      ActiveMerchant::Billing::Response.new(false, "PayPal dropped the connection.")
    end
    process_response(response)
  end
  
  def paypal?
    gateway == "paypal" || express_token?
  end
  
  def paypal_url(r, c)
    response = Rails.configuration.paypal.setup_purchase(total_price.cents, setup_paypal_options(r, c))
    Rails.configuration.paypal.redirect_url_for response.token
  end
  
  def setup_paypal_options(r, c)
    {
      :return_url => r,
      :cancel_return_url => c,
      :no_shipping => !requires_shipping?,
      :description => contents,
    }
  end

  def express_purchase_options
    {
      :token => express_token,
      :payer_id => express_payer_id,
      :description => contents
    }
  end
  
  def express_token=(token)
    self[:express_token] = token
    if new_record? && token.present? && express_payer_id.blank?
      details = Rails.configuration.paypal.details_for token
      self.express_payer_id = details.payer_id
      self.first_name = details.params["first_name"]
      self.last_name = details.params["last_name"]
      self.shipping_name = details.address["name"]
      self.shipping_address = details.address["address1"]
      self.shipping_address_2 = details.address["address2"]
      self.shipping_city = details.address["city"]
      self.shipping_state = details.address["state"]
      self.shipping_zip = details.address["zip"]
      self.shipping_phone = details.params["contact_phone"]
    end
  end
  
end