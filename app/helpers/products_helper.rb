module ProductsHelper

  def display_percentage(p)
    f = p.display_discount(current_user).to_f/p.retail_price.to_f*100
    number_to_percentage [f.floor, 0].max, :precision => 0
  end

  def buy_now_percentage(i, a)
    f = (1-(i.amount_in_cents + a.going_price_in_cents)/a.retail_price_in_cents.to_f)*100
    number_to_percentage [f.floor, 0].max, :precision => 0
  end

  # Takes order or product
  def shipping_price(p)
    p.shipping_price.zero? ? "Free!" : number_to_currency(p.shipping_price)
  end

  def facebook_share_product(p)
    link_to image_tag("icons/facebook.png", size: "32x32"), "http://www.facebook.com/sharer.php?u=#{product_url p}&t=#{p.name}"
  end
  
  def return_policy(p)
    if [12,13,14,15,28,29].include?(p.category_id) then "Gift cards are not eligible for returns"
    else "Return within 14 days for any reason"
    end
  end

end
