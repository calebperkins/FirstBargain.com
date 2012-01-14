require 'digest/md5'
require 'net/https'

module CCBill
  CCBILL_PACKS = {30 => "9133", 50 => "6048", 100 => "3969", 200 => "3725"}.freeze
  
  def ccbill_url
    p = {
      :clientAccnum => "942370",
      :uid => account.single_access_token,
      :buyable => "#{kind}-#{buyable_id}",
      :email => account.email,
      :customTaxPrice => sales_tax.to_f,
      :customShippingPrice => shipping_price.to_f,
      :customOrderId => (1 + rand(999998)),
      :customSkuCode => buyable_id,
      :customProductName => contents,
      :customUnitPrice => subtotal.to_f,
      :customQuantity => 1,
      :referer => "organic",
    }
    if is_a? BidOrder
      p[:clientSubacc] = "0000"
      p[:formName] = "942370-0000cc-1"
      p[:allowedTypes] = CCBILL_PACKS[buyable_id]
    else
      p[:clientSubacc] = "0001"
      p[:formName] = "942370-0001cc-1"
      p[:formPrice] = total_price.to_f
      p[:formPeriod] = "2"
      p[:currencyCode] = "840"
      p[:formDigest] = Digest::MD5.hexdigest("#{total_price.to_f}#{p[:formPeriod]}#{p[:currencyCode]}NLMX8fmxaROkppOElM27fTbE")
    end
    if requires_shipping?
      p[:shipping_name] = shipping_name
      p[:shipping_address] = shipping_address
      p[:shipping_address_2] = shipping_address_2
      p[:shipping_city] = shipping_city
      p[:shipping_state] = shipping_state
      p[:shipping_country] = shipping_country
      p[:shipping_phone] = shipping_phone
      p[:shipping_zip] = shipping_zip
      p[:customer_fname] = shipping_name.split.first
      p[:customer_lname] = shipping_name.split.last
      p[:address1] = shipping_address_2.blank? ? shipping_address : "#{shipping_address} #{shipping_address_2}"
      p[:city] = shipping_city
      p[:state] = shipping_state
      p[:zipcode] = shipping_zip
      p[:country] = shipping_country
      p[:phone_number] = shipping_phone
    end
    "https://bill.ccbill.com/jpost/signup.cgi?#{p.to_query}"
  end
  
  def process_postback(postback)
    success = postback["reasonForDecline"].blank?
    message = (success ? "Thank you!" : postback["reasonForDecline"])
    options = {
      :authorization => postback["subscription_id"],
      :fraud_review => false,
      :avs_result => {},
      :cvv_result => ''
    }
    ActiveMerchant::Billing::Response.new(success, message, postback, options)
  end
  
  def create_fulfillment!
    p = {
      :transactionId => transactions.first.authorization,
      :shippingCompany => shipping_company,
      :trackingId => tracking_id,
      :action => "createFulfillment",
      :clientAccnum => "942370",
      :usingSubacc => "0001",
      :username => "1stbargn",
      :password => "mybargn1"
    }
    req = Net::HTTP::Get.new "https://datalink.ccbill.com/utils/subscriptionManagement.cgi?#{p.to_query}"
    con = Net::HTTP.new "datalink.ccbill.com", 443
    con.use_ssl = true
    con.start {|http| http.request req}
  end
  
  module ClassMethods
    def from_ccbill(p)
      user = Account.find_by_single_access_token p["uid"]
      k, b = p["buyable"].try :split, "-"
      params = {
        :kind => k,# us
        :buyable => b,# us
        :ip_address => p["ip_address"],
        :first_name => p["customer_fname"],
        :last_name => p["customer_lname"],
        :card_type => p["cardType"],
        :card_expires_on => 20.years.from_now,
        :shipping_name => (p["shipping_name"].blank? ? p["customer_fname"] + p["customer_lname"] : p["shipping_name"]),#us
        :shipping_address => p["shipping_address"],#us
        :shipping_address_2 => p["shipping_address_2"],#us
        :shipping_city => p["shipping_city"], #us
        :shipping_state => p["shipping_state"],#us
        :shipping_country => p["shipping_country"], #us
        :shipping_phone => p["shipping_phone"],#us
        :billing_address => p["address1"],
        :billing_address_2 => "",
        :billing_city => p["city"],
        :billing_state => p["state"],
        :billing_country => p["country"],
        :billing_phone => p["phone_number"],
        :shipping_zip => p["shipping_zip"], # us
        :billing_zip => p["zipcode"],
      }
      factory(params, user)
    end
  end
end