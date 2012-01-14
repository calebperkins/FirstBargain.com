# encoding: utf-8

# Accounts

Factory.define :account do |f|
  f.sequence(:username) { |n| "foo#{n}" }   
  f.sequence(:email) { |n| "foo#{n}@example.com" } 
  f.birth_date {20.years.ago}
  f.password 'foobar'
  f.password_confirmation {|u| u.password} 
  f.sequence(:registration_ip) { |n| "127.0.0.#{n}"}
  f.current_login_ip {|u| u.registration_ip}
  f.last_login_ip {|u| u.registration_ip}
  f.skip_session_maintenance true
end

# Auctions

Factory.define :auction do |f|
  f.association :product
  f.ending_at {1.hour.from_now}
  f.retail_price Money.new(1995)
end

Factory.define :featured_auction do |f|
  f.association :auction
  f.name "Hey! Buy This!"
  f.description "This item is really great. You should bid on it."
  f.image_url {|fa| fa.auction.product.main_picture.url :medium}
end

# Product

Factory.define :product do |f|
  f.sequence(:name) {|n| "Lowe's $25 Gift Card #{n}"}
  f.summary "Lowe's $25 Gift Card"
  f.description "The Lowe’s Gift Card is the perfect gift for everything home with the choice of over 50,000 items. Building supplies, tools, appliances, home improvement services, do it yourself help and hundreds of ideas to decorate and personalize your home. From rooftops to basements, ceilings to floors, indoors to out, you can find it all at Lowe’s."
  f.retail_price Money.new(2500)
  f.main_picture File.open("#{Rails.root}/test/fixtures/products/lowes-gift-card.jpg")
  f.tax 0.to_money
  f.cost {|p| p.retail_price}
  f.association :category
end

# Categories

Factory.define :category do |f|
  f.name "Gift Cards"
end

# Orders

Factory.define :order do |f|
  f.association :account
  f.ip_address "127.0.0.1"
  f.first_name "Caleb"
  f.last_name "Perkins"
  #f.card_type "mastercard"
  #f.card_number "4111111111111111"
  #f.card_verification "123"
  #f.card_expires_on 1.year.from_now
  f.billing_address "1615 SW 158 Avenue"
  f.billing_address_2 ""
  f.billing_city "Pembroke Pines"
  f.billing_state "Florida"
  f.billing_zip "33027"
  f.billing_phone "607-351-4028"
  f.shipping_name {|o| o.billing_name}
  f.shipping_address {|o| o.billing_address}
  f.shipping_address_2 {|o| o.billing_address_2}
  f.shipping_city {|o| o.billing_city}
  f.shipping_state {|o| o.billing_state}
  f.shipping_zip {|o| o.billing_zip}
  f.shipping_phone {|o| o.billing_phone}
end

Factory.define :bid_order, :parent => :order, :class => BidOrder do |f|
  f.quantity 50
end

Factory.define :auction_order, :parent => :order, :class => AuctionOrder do |f|
  f.association :auction
end

# Contacts

Factory.define :contact do |f|
  f.email "caleb@example.com"
  f.subject "A simple test"
  f.message "Hope this works!"
end

Factory.define :investment do |f|
end

Factory.define :bid do |f|
end

Factory.define :bid_bot do |f|
  f.association :account
  f.association :auction
  f.bid_from 0.to_money
  f.bids_left 3
end