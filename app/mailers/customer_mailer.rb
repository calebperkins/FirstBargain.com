class CustomerMailer < ActionMailer::Base
  default :from => "FirstBargain.com <support@firstbargain.com>"
  layout "notifier", :except => :invitation

  
  def won_auction(auction_id)
    @auction = Auction.find auction_id
    @account = @auction.winning_bid.account
    mail :to => @account.email, :subject => "You Won: #{@auction.product.name}", :"X-SMTPAPI" => '{"category": "Win Notification"}'
  end

  def forgot_password(account_id)
    @account = Account.find account_id
    mail :to => @account.email, :"X-SMTPAPI" => '{"category": "Password Reset"}'
  end
  
  def activation_instructions(account_id)
    @account = Account.find account_id
    mail :to => @account.email, :subject => "Verify Email Address", :"X-SMTPAPI" => '{"category": "Account Activation"}'
  end
  
  def welcome(account_id)
    @account = Account.find account_id
    mail :to => @account.email, :subject => "Welcome to FirstBargain",:"X-SMTPAPI" => '{"category": "Account Welcome"}'
  end
  
  def order_confirmation(order_id)
    @order = Order.find order_id
    @account = @order.account
    mail :to => @account.email, :"X-SMTPAPI" => '{"category": "Order Confirmation"}'
  end
  
  def shipment_confirmation(order_id)
    @order = Order.find order_id
    @account = @order.account
    mail :to => @account.email, :"X-SMTPAPI" => '{"category": "Shipping Confirmation"}'
  end
  
  def invitation(json)
    hash = JSON.parse json
    @message = hash["message"]
    mail :bcc => hash["addresses"], :subject => "#{hash["name"]} grabbed you an invitation to FirstBargain.com", :"X-SMTPAPI" => '{"category": "Invite"}', :from => "FirstBargain <invites@firstbargain.com>"
  end
  
end
