require File.expand_path("../environment", __FILE__)
require 'net/http'

job "bid_bot" do |args|
  if $redis.sismember("auction_#{args['id']}_job_ids", args["redis_job_id"])
    a = Auction.find(args["id"])
    BidBot.pool(a).any? do |bot|
      bot.bid!
    end
  end
end

job "emails.won_auction" do |args|
  a = Auction.find(args["id"])
  if a.finished?
    CustomerMailer.won_auction(args["id"]).deliver if a.account_id? 
  else
    t = a.ending_at + 7.minutes
    Stalker.enqueue("emails.won_auction", args, {delay: (t - Time.now).round})
  end
end

job "emails.customer" do |args|
  begin
    m = CustomerMailer.public_send(args["method"], args["params"])
    m.deliver
  rescue Net::SMTPFatalError
    Account.find_by_email(m.to.first).try(:update_attribute, :good_email, false)
  end
end

job "emails.contact_form" do |hash|
  StaffMailer.inquiry(hash).deliver	 	
end

# CCBill shipment confirmations
job "Order" do |args| 
  o = Order.find(args["order_id"])
  o.create_fulfillment! if o.requires_shipping? 	
end
