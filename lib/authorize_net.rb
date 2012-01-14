module AuthorizeNet
  
  module ClassMethods
    attr_accessor :card_number, :card_verification
    before_validation :set_shipping_from_billing
    validate :validate_card, on: :create, :unless => :paypal?
    validates :billing_phone, :billing_address, :billing_city, :billing_state, :billing_zip, :presence => true, :unless => :paypal?, on: :create
    validates :shipping_name, :shipping_phone, :shipping_address, :shipping_city, :shipping_state, :shipping_zip, presence: true, if: -> {requires_shipping? and not paypal?}, on: :create
  end
  
  def self.included(klass)
    klass.class_eval do
      private :set_shipping_from_billing, :validate_card, :standard_purchase_options
    end
  end
  
  def set_shipping_from_billing
    if different_shipping == "0" and not paypal?
      %w[name address address_2 city state zip country phone].each do |sym|
        b = public_send("billing_#{sym}")
        public_send("shipping_#{sym}=", b)
      end
    end
  end
  
  def validate_card
    credit_card.errors.full_messages.each {|msg| errors[:base] << msg} if credit_card.invalid?
  end
  
  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => card_type,
      :number             => card_number,
      :verification_value => card_verification,
      :month              => card_expires_on.try(:month),
      :year               => card_expires_on.try(:year),
      :first_name         => first_name,
      :last_name          => last_name
    )
  end
  
  def standard_purchase_options
    b = {
      :name => billing_name,
      :address1 => billing_address,
      :address2 => billing_address_2,
      :city => billing_city,
      :state => billing_state,
      :zip => billing_zip,
      :country => billing_country,
      :phone => billing_phone
    }
    s = if requires_shipping? then {
      :name => shipping_name,
      :address1 => shipping_address,
      :address2 => shipping_address_2,
      :city => shipping_city,
      :state => shipping_state,
      :zip => shipping_zip,
      :country => shipping_country,
      :phone => shipping_phone
    }
    else b
    end
    {
      :order_id => id,
      :ip => ip_address,
      :customer => account.username,
      :description => contents,
      :email => account.email,
      :billing_address => b,
      :shipping_address => s
    }
  end
  
end