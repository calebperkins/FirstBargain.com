module AuctionsHelper

  def fb_share_auction_description(auction)
    "#{auction.product.name} going at #{number_to_currency auction.going_price} and will end in #{time_ago_in_words auction.ending_at}. Bid now and save big!"
  end

  def auction_ids(*auctions)
    auctions.flatten.map {|a| a.id}.to_json
  end
  
  def auction_classes(a)
    classes = ["price-#{a.price_increment_in_cents}", "timer-#{a.timer_reset}"]
    classes << if a.finished? then "ended-trigger"
    elsif a.beginner? then "beginner"
    elsif a.hot then "hot"
    end
  end
  
  def auction_prices(*auctions)
    p = {}
    auctions.flatten.each {|a| p[a.id] = a.retail_price.to_f}
    p.to_json
  end

  def facebook_share_auction(auction)
    p = {:u => auction_url(auction), :t => "Great deal on #{auction.product.name}"}
    link_to "Share", "http://www.facebook.com/sharer.php?#{p.to_query}", :name => "fb_share", :type => "button_count"
  end

  def bidder(u, add_you = false)
    u == current_user.try(:username) ? "<strong>#{u}#{" (You!)" if add_you}</strong>".html_safe : u
  end

  def increment_title(a)
    "Each bid raises the auction price by #{number_to_currency a.price_increment}"
  end

  def timer_title(a)
    "When the clock is under #{a.timer_reset} seconds, each bid will reset the clock to #{a.timer_reset} seconds"
  end

  def picture_url(a)
    request.protocol + request.host_with_port + a.product.main_picture.url
  end

end
