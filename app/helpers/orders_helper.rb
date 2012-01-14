module OrdersHelper
  
  def hide_card_number(card_number)
    card_number.sub /(\S){12}/, "XXXX-XXXX-XXXX-"
  end
  
  def kind(o)
    return params[:kind] if params[:kind].present?
    case o.type
    when "AuctionOrder" then "auction"
    when "BuyNowOrder" then "buynow"
    when "RewardOrder" then "reward"
    else "bidpack"
    end
  end
  
  def buyable(o)
    params[:buyable].blank? ? o.buyable_id : params[:buyable]
  end
  
  def price_title(o)
    case o.type
    when "AuctionOrder" then "Auction Price"
    when "BuyNowOrder" then "BuyNow Price"
    else "Regular Price"
    end
  end
  
  def order_picture(o)
    pic = case o.type
    when "AuctionOrder", "BuyNowOrder" then o.auction.product.main_picture.url :medium
    when "BidOrder" then "bidpacks/#{o.buyable_id}-bids.jpg"
    when "RewardOrder" then o.product.main_picture.url :medium
    end
    image_tag(pic, size: "280x260")
  end
  
  def order_contents_title(o)
    path = case o.type
    when "AuctionOrder" then "Auction Won"
    when "BuyNowOrder" then "Buy Now"
    when "BidOrder" then "Bid Pack"
    when "RewardOrder" then "Members Shop"
    end
  end
  
  def order_contents_link(o)
    path = case o.type
    when "AuctionOrder", "BuyNowOrder" then auction_path(o.auction)
    when "BidOrder" then bids_path
    when "RewardOrder" then product_path(o.product)
    end
    link_to o.contents, path
  end
  
  def link_to_order(o)
    case o.type
    when "AuctionOrder" then link_to o.contents, auction_path(o.auction)
    when "BuyNowOrder" then link_to o.contents, auction_path(o.auction), :class => "auction-buy-now"
    when "BidOrder" then o.contents
    when "RewardOrder" then content_tag(:span, o.contents, :class => "membershop-purchase")
    end
  end
  
  def order_class(o)
    case o.type
    when "AuctionOrder" then "auction-win"
    when "BuyNowOrder" then "auction-buy-now"
    when "BidOrder" then "bid-pack-purchase"
    when "RewardOrder" then "membershop-purchase"
    end
  end
  
end
