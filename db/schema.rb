# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110802152801) do

  create_table "accounts", :force => true do |t|
    t.integer  "credits",              :default => 0
    t.integer  "bonuses",              :default => 0
    t.integer  "points_in_cents",      :default => 0
    t.date     "birth_date"
    t.boolean  "verified",             :default => false
    t.string   "username",                                :null => false
    t.string   "email",                                   :null => false
    t.string   "encrypted_password",                      :null => false
    t.string   "password_salt",                           :null => false
    t.string   "persistence_token",                       :null => false
    t.string   "single_access_token",                     :null => false
    t.string   "perishable_token",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
    t.boolean  "has_purchased",        :default => false
    t.integer  "cumulative_credits",   :default => 0
    t.integer  "cumulative_bonuses",   :default => 0
    t.boolean  "active",               :default => true
    t.string   "registration_ip"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.datetime "last_username_change"
    t.boolean  "good_email",           :default => true
    t.string   "source"
    t.datetime "last_request_at"
    t.text     "notes"
    t.boolean  "subscribed",           :default => false, :null => false
    t.string   "utm_medium"
    t.string   "utm_source"
    t.string   "utm_campaign"
    t.string   "utm_term"
    t.string   "utm_content"
    t.boolean  "bids_purchased",       :default => false
  end

  add_index "accounts", ["email"], :name => "index_accounts_on_email", :unique => true
  add_index "accounts", ["perishable_token"], :name => "index_accounts_on_perishable_token", :unique => true
  add_index "accounts", ["persistence_token"], :name => "index_accounts_on_persistence_token", :unique => true
  add_index "accounts", ["registration_ip"], :name => "index_accounts_on_registration_ip"
  add_index "accounts", ["single_access_token"], :name => "index_accounts_on_single_access_token", :unique => true
  add_index "accounts", ["username"], :name => "index_accounts_on_login", :unique => true

  create_table "addresses", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "address_2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country",    :default => "US"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "label"
  end

  add_index "addresses", ["account_id"], :name => "index_addresses_on_account_id"

  create_table "approvals", :force => true do |t|
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "approvals", ["ip"], :name => "index_approvals_on_ip", :unique => true

  create_table "auctions", :force => true do |t|
    t.integer  "product_id"
    t.integer  "account_id"
    t.datetime "ending_at"
    t.integer  "price_increment_in_cents", :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "redeemed",                 :default => false
    t.integer  "going_price_in_cents",     :default => 0
    t.boolean  "hot",                      :default => false
    t.integer  "retail_price_in_cents"
    t.boolean  "is_buy_now",               :default => false
    t.integer  "timer_reset",              :default => 30
    t.integer  "investment_id"
    t.boolean  "beginner",                 :default => false
    t.boolean  "finished",                 :default => false, :null => false
  end

  add_index "auctions", ["account_id"], :name => "index_auctions_on_account_id"
  add_index "auctions", ["ending_at"], :name => "index_auctions_on_ending_at"

  create_table "bid_bots", :force => true do |t|
    t.integer  "account_id"
    t.integer  "auction_id"
    t.integer  "bid_from_in_cents", :default => 0
    t.integer  "bids_left"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bid_bots", ["auction_id", "account_id"], :name => "index_bid_bots_on_auction_id_and_account_id", :unique => true
  add_index "bid_bots", ["auction_id", "bids_left", "bid_from_in_cents", "account_id"], :name => "by_pool"

  create_table "bids", :force => true do |t|
    t.integer  "account_id"
    t.integer  "auction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "paid",       :default => true
    t.string   "username"
    t.boolean  "botted",     :default => false
  end

  add_index "bids", ["auction_id"], :name => "index_bids_on_auction_id"

  create_table "bookmarks", :force => true do |t|
    t.integer  "account_id"
    t.integer  "auction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bookmarks", ["account_id"], :name => "index_bookmarks_on_account_id"

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coupon_uses", :force => true do |t|
    t.integer  "account_id"
    t.integer  "coupon_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coupon_uses", ["account_id", "coupon_id"], :name => "index_coupon_uses_on_account_id_and_coupon_id", :unique => true

  create_table "coupons", :force => true do |t|
    t.string   "code"
    t.string   "summary"
    t.datetime "ends_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bonuses"
    t.integer  "uses_left"
  end

  add_index "coupons", ["code"], :name => "index_coupons_on_code"

  create_table "featured_auctions", :force => true do |t|
    t.integer  "auction_id"
    t.string   "name"
    t.text     "description"
    t.string   "image_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "investments", :force => true do |t|
    t.integer  "account_id"
    t.integer  "amount_in_cents", :default => 0
    t.integer  "credits_used",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "auction_id"
    t.boolean  "expired",         :default => false
    t.integer  "bonuses_used",    :default => 0
  end

  add_index "investments", ["account_id", "auction_id"], :name => "index_investments_on_account_id_and_auction_id", :unique => true

  create_table "orders", :force => true do |t|
    t.string   "state",                   :default => "pending"
    t.integer  "account_id"
    t.string   "ip_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "card_type"
    t.date     "card_expires_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "shipped_at"
    t.string   "confirmation"
    t.string   "shipping_name"
    t.string   "shipping_address"
    t.string   "shipping_address_2"
    t.string   "shipping_city"
    t.string   "shipping_state"
    t.string   "shipping_country",        :default => "US"
    t.string   "shipping_phone"
    t.string   "billing_address"
    t.string   "billing_address_2"
    t.string   "billing_city"
    t.string   "billing_state"
    t.string   "billing_country",         :default => "US"
    t.string   "billing_phone"
    t.string   "shipping_zip"
    t.string   "billing_zip"
    t.string   "express_token"
    t.string   "express_payer_id"
    t.integer  "subtotal_in_cents"
    t.integer  "shipping_price_in_cents"
    t.integer  "point_discount_in_cents"
    t.integer  "buyable_id"
    t.string   "type"
    t.integer  "sales_tax_in_cents",      :default => 0
    t.string   "tracking_id",             :default => ""
    t.string   "shipping_company",        :default => ""
  end

  add_index "orders", ["account_id"], :name => "index_orders_on_account_id"
  add_index "orders", ["state"], :name => "index_orders_on_state"

  create_table "pictures", :force => true do |t|
    t.integer  "product_id"
    t.string   "data"
    t.string   "summary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pictures", ["product_id"], :name => "index_pictures_on_product_id"

  create_table "products", :force => true do |t|
    t.string   "name"
    t.string   "summary"
    t.text     "description"
    t.integer  "retail_price_in_cents",   :default => 0
    t.string   "main_picture"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shipping_price_in_cents", :default => 0
    t.integer  "max_discount_in_cents",   :default => 0
    t.boolean  "visible",                 :default => true
    t.integer  "bonuses",                 :default => 0
    t.boolean  "requires_shipping",       :default => true
    t.integer  "category_id"
    t.boolean  "widget_worthy",           :default => false
    t.integer  "tax_in_cents",            :default => 0
    t.integer  "cost_in_cents",           :default => 0
    t.boolean  "discontinued",            :default => false
  end

  add_index "products", ["category_id"], :name => "index_products_on_category_id"
  add_index "products", ["visible"], :name => "index_products_on_visible"

  create_table "transactions", :force => true do |t|
    t.integer  "order_id"
    t.integer  "amount_in_cents", :default => 0
    t.boolean  "success"
    t.string   "authorization"
    t.string   "message"
    t.string   "action"
    t.text     "params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["order_id"], :name => "index_transactions_on_order_id"

  create_table "viewers", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
