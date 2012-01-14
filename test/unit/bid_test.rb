require 'test_helper'

class BidTest < ActiveSupport::TestCase
  
  # Rewrite this
  test "cannot participate in more active auctions than win limit permits" do
    u = Factory :account, :credits => 500
    Rails.configuration.daily_win_limit.times do
      assert_bid u
    end
    assert_no_bid u, nil, "reached potential win limit"
  end
  
  test "daily win limits" do
    u = Factory :account, :credits => 500
    Rails.configuration.daily_win_limit.times do
      assert_bid u, nil, "should go through"
    end
    assert_no_bid u, nil, "reached daily win limit"
    a = Factory :auction, :ending_at => 2.days.from_now
    Timecop.travel 1.day
    assert_equal 0, u.wins_today.size
    assert_equal 3, u.wins_this_month.size
    assert_bid u, a, "new day. should go through."
  end
  
  test "can win only one of same expensive product" do
    u = Factory :account, :credits => 500
    a = Factory :auction, :retail_price => Rails.configuration.price_threshold
    a2 = Factory :auction, :retail_price => Rails.configuration.price_threshold, :ending_in => 5.days, :product => a.product
    assert_bid u, a
    finish a
    assert_no_bid u, a2, "user shouldn't be able to win this again"
  end
  
  test "can compete in beginner auctions only if you have not won anything" do
    u = Factory :account, :credits => 500
    a = Factory :auction, :beginner => true
    a2 = Factory :auction, :beginner => true, :ending_in => 5.days
    assert_bid u, a
    Timecop.travel 2.hours
    assert_no_bid u, a2
  end
  
  test "can compete in only 1 beginner auction at a time" do
    u = Factory :account, :credits => 500
    a = Factory :auction, :beginner => true
    a2 = Factory :auction, :beginner => true
    a3 = Factory :auction
    assert_bid u, a
    assert_no_bid u, a2
    assert_bid u, a3
  end
  
end
