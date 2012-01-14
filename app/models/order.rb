require 'ccbill'
require 'paypal'

# = Making a CCBill purchase
# * User goes through OrdersController and gets redirected to CCBill. CCBill redirects them to their orders page.
# * In background:
# ** CCBill sends a postback to CCBillController
# ** CCBillController calls: process_postback -> process_response
# = Making a PayPal purchase
class Order < ActiveRecord::Base
  include CCBill
  extend CCBill::ClassMethods
  include PayPal
  
  US_STATES = %w[AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH OK OR PA RI SC SD TN TX UT VA VT WA WI WV WY].freeze

  money :shipping_price
  money :point_discount
  money :subtotal
  money :sales_tax
  has_many :transactions, :dependent => :destroy, inverse_of: :order
  belongs_to :account, inverse_of: :orders
  attr_accessor :different_shipping, :gateway, :kind, :buyable
  attr_protected :shipping_price, :point_discount, :subtotal

  validates :account_id, :buyable_id, :presence => true
  validates :shipping_address, :shipping_address_2, if: -> {requires_shipping? and paypal?}, on: :create, format: {without: /\b[P|p]*(OST|ost)*\.*\s*[O|o|0]*(ffice|FFICE)*\.*\s*[B|b][O|o|0][X|x]\b/, message: "cannot be a PO Box, sorry"}

  state_machine :initial => :unsaved do
    event :capture do
      transition [:unsaved, :pending] => :paid, :if => :requires_shipping?
      transition [:unsaved, :pending] => :complete
    end
    event :capture_later do
      transition :unsaved => :pending
    end
    event :decline do
      transition [:unsaved, :pending] => :declined
    end
    event :review do
      transition [:unsaved, :pending] => :under_review
    end
    event :approve do
      transition :under_review => :paid, :if => :requires_shipping?
      transition :under_review => :complete
    end
    event :ship do
      transition :paid => :shipped
    end
    event :void do
      transition [:under_review, :paid, :complete, :shipped] => :void
    end
    event :refund do
      transition [:paid, :complete, :shipped] => :refunded
    end
    after_transition :from => :unsaved, on: [:capture, :review], :do => :single_step_purchase
    after_transition :from => :pending, on: [:capture, :review], :do => :finish_purchase
    before_transition on: :ship, :do => :complete_shipment
    after_transition :from => :pending, :to => :declined, :do => :complete_reset
    after_transition on: :capture_later, :do => :setup_purchase
  end

  scope :good, without_state(:declined, :void, :refunded)
  scope :good_between, ->(from,to) {good.where("orders.created_at" => from..to)}

  STATES = state_machine.states.map {|s| [s.human_name, s.name]}.freeze
  SEARCHABLE = ["accounts.username", "orders.id"].map {|a| "#{a} LIKE ?"}.freeze
  MINIMUM_CHARGE = 2.95.to_money.freeze

  def self.search(state = nil, string = nil)
    state = :unsaved unless state.present? # state may be a string
    x = with_state(state.to_sym).order('orders.id DESC')
    if string.present? then x.joins(:account).where([SEARCHABLE.join(" OR ")] + SEARCHABLE.map {string})
    else x.includes(:account)
    end
  end

  def self.factory(source, user, ip = nil, set_attr = true)
    source.to_options!
    b = source[:buyable] || source[:quantity] || source[:buyable_id]
    o = case source[:kind]
    when "auction" then AuctionOrder.new :account => user, :auction => Auction.find(b)
    when "buynow" then BuyNowOrder.new :account => user, :auction => Auction.find(b)
    when "reward" then RewardOrder.new :account => user, :product => Product.find(b)
    else BidOrder.new :account => user, :quantity => b
    end
    o.ip_address = ip
    o.attributes = source if set_attr
    o
  end

  def self.revenue
    result = sum("subtotal_in_cents + shipping_price_in_cents + sales_tax_in_cents - point_discount_in_cents")
    if result.is_a?(Hash) then result.each_with_object({}) {|(k,v), acc| acc[k] = Money.new(v.to_i)}
    else Money.new(result.to_i)
    end
  end

  def self.distinct_purchasers
    select("DISTINCT orders.account_id").size
  end

  def process_response(response)
    transactions.create! :action => "purchase", :amount => total_price, :response => response
    if response.fraud_review?
      account.make_first_purchase
      send_confirmation
      review!
    elsif response.success?
      account.make_first_purchase
      send_confirmation
      capture!
    else decline!
    end
  end

  # Send remote order fulfillment request to CCBill
  def self.perform(order_id)
    o = find(order_id)
    o.create_fulfillment! if o.requires_shipping?
  end

  def total_price
    [subtotal + sales_tax + shipping_price - point_discount, MINIMUM_CHARGE].max
  end

  def kind
    raise NotImplementedError
  end

  def contents
    raise NotImplementedError
  end

  def billing_name
    "#{first_name} #{last_name}"
  end

  def requires_shipping?
    true
  end

  def bid_pack?
    false
  end

  def to_user_session
    x = as_json :except => [:created_at, :confirmation, :shipped_at, :point_discount_in_cents, :card_type, :updated_at, :tracking_id, :subtotal_in_cents, :shipping_company, :shipping_price_in_cents, :account_id, :sales_tax_in_cents, :card_expires_on, :state, :ip_address]
    x["kind"] = kind
    x
  end

  private

  def send_confirmation
    Stalker.enqueue("emails.customer", {method: :order_confirmation, params: id}) if paypal? && account.good_email?
  end

  def complete_shipment
    self.shipped_at = Time.now
    Stalker.enqueue("emails.customer", {method: :shipment_confirmation, params: id})
    Stalker.enqueue("Order", {order_id: id}) if tracking_id.present? && tracking_id_changed?
  end
  
  def single_step_purchase
    setup_purchase
    finish_purchase
  end

  protected

  def complete_reset
  end

  # Part one of a two-step purchase. Should be used to prevent user from redeeming twice, et cetera.
  def setup_purchase
  end
  
  # Part two of a two-step purchase. Should be used to reward user with bids, et cetera.
  def finish_purchase
  end

end
