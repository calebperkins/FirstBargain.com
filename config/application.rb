require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module FirstBargain
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    #config.active_record.observers = :bid_observer, :order_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Pacific Time (US & Canada)'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    
    config.action_view.javascript_expansions[:cdn] = %w[
      //ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js
      //ajax.googleapis.com/ajax/libs/jqueryui/1.8.13/jquery-ui.min.js
    ]

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    
    config.cache_store = :redis_store, {db: 1}
    
    # Override me in production.rb
    config.cdn_enabled = false

    config.active_record.include_root_in_json = false
    
    config.buy_now_expiration = 1.day
    config.won_auction_expiration = 1.week
    config.referral_bonus = 20
    config.subscription_bonus = 0
    config.monthly_win_limit = 10
    config.daily_win_limit = 3
    config.price_threshold = Money.new(20000) # one $200 item per month
    config.admins = [1,2,3]
    config.bid_unit_price = Money.new(75)
    config.banned_domains = /mailinator|trashymail|mailexpire|maileater|jetable|spambox|spamhole|pookmail/i

    config.recaptcha_public = ENV["RECAPTCHA_PUBLIC"]
    config.recaptcha_private = ENV["RECAPTCHA_PRIVATE"]

    Time::DATE_FORMATS[:default] = "%m/%d/%y - %I:%M%p"
    Time::DATE_FORMATS[:order_history] = "%m-%d-%Y<span>%I:%M %p %Z</span>"
    Time::DATE_FORMATS[:admin] = "%m/%d/%y - %I:%M:%S%p"
    Time::DATE_FORMATS[:auction] = "%m/%d %I:%M %p %Z"
    Time::DATE_FORMATS[:bid] = "%r"
  end
end
