ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "authlogic/test_case"
require "#{Rails.root}/db/seeds.rb"

Jammit.load_configuration("#{Rails.root}/config/assets.yml")

class ActiveSupport::TestCase
    
  # Shortcut to bid on an auction. Creates user and auction if not supplied
  def assert_bid(user = nil, auction = nil, msg = "Could not bid")
    user ||= Factory :account, :credits => 500
    auction ||= Factory :auction
    bid = Bid.new(:account => user, :auction => auction)
    saved = bid.save
    assert_block "#{msg}: #{bid.errors[:base]}" do
      saved
    end
  end
  
  def bid!(user, auction)
    Bid.create!(:account => user, :auction => auction)
  end
  
  def assert_no_bid(user = nil, auction = nil, msg = "Should not have bid")
    user ||= Factory :account
    auction ||= Factory :auction
    assert_block msg do
      not Bid.new(:account => user, :auction => auction).save
    end
  end
  
  # Fast forward to a little after the auction has ended
  def finish(auction)
    Timecop.travel(auction.ending_at + 1.second)
  end
  
  def assert_logged_out
    assert_nil controller.session["user_credentials"]
  end
  
end
