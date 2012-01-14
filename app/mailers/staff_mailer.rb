class StaffMailer < ActionMailer::Base
  default :from => "FirstBargain <noreply@firstbargain.com>"

  def inquiry(hash)
    @contact = Contact.new(hash)
    mail :to => "FirstBargain Support <support@firstbargain.com>", :subject => @contact.subject, :"X-SMTPAPI" => '{"category": "Contact Form"}'
  end
  
  def daily_activity_report
    @now = Time.current.beginning_of_day
    @since = @now - 1.day
    @bidpacks = BidOrder.good_between(@since, @now)
    @auctions = AuctionOrder.good_between(@since, @now)
    @buynows = BuyNowOrder.good_between(@since, @now)
    @rewards = RewardOrder.good_between(@since, @now)
    @accounts = Account.member_between(@since,@now)
    # Affiliates
    @a_signups = @accounts.group(:source).size
    @a_bid_count = @bidpacks.joins(:account).group("accounts.source").size
    @a_bid_value = @bidpacks.joins(:account).group("accounts.source").revenue
    mail :from => "FirstBargain Daily Report <noreply@firstbargain.com>", :to => ["taichi@firstbargain.com", "jing@firstbargain.com", "corporate@expedientshopping.com"], :"X-SMTPAPI" => '{"category": "Finance Reports"}'
  end
  
  def weekly_activity_report
    @now = Time.current.beginning_of_day
    @since = @now - 1.week
    @new_signups = Account.member_between(@since,@now).size
    b = BidOrder.good_between(@since, @now).includes(:account)
    @new_purchasers = b.where("accounts.created_at > ?", @since).distinct_purchasers
    @old_purchasers = b.where("accounts.created_at < ?", @since).distinct_purchasers
    @new_bid_revenue = b.where("accounts.created_at > ?", @since).revenue
    @old_bid_revenue = b.where("accounts.created_at < ?", @since).revenue
    mail :from => "FirstBargain Weekly Report <noreply@firstbargain.com>", :to => ["taichi@firstbargain.com", "jing@firstbargain.com", "corporate@expedientshopping.com"], :"X-SMTPAPI" => '{"category": "Finance Reports"}'
  end

end
