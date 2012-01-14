require 'test_helper'

class AccountTest < ActiveSupport::TestCase

  test "search by various items" do
    a = Factory :account, :source => "dailymakeover"
    assert Account.search(a.username).present?
    assert Account.search(a.email).present?
    assert Account.search(a.source).present?
  end
  
  test "search with blank shows all" do
    2.times {Factory :account}
    assert_equal Account.search("").size, 2
  end
  
  test "winnings expire" do
    u = Factory :account
    a = Factory :auction, :account => u
    Timecop.travel(a.ending_at + Rails.configuration.won_auction_expiration)
    assert_equal 0, u.winnings.size
  end
  
  test "active auctions should increase and expire" do
    u = Factory :account, :credits => 5
    assert_bid u
    assert_equal 1, u.active_auctions.count
    Timecop.travel 1.day
    assert_equal 0, u.active_auctions.reload.count
  end
  
  test "wins this month" do
    Timecop.freeze do
      u = Factory :account, :credits => 5
      assert_bid u
      Timecop.travel 1.day
      assert_equal 1, u.wins_this_month.size
      Timecop.travel 1.month
      assert_equal 0, u.reload.wins_this_month.size, "wins should reset every month"
    end
  end
  
  test "wins today" do
    Timecop.freeze do
      u = Factory :account, :credits => 5
      assert_equal 0, u.wins_today.size
      assert_bid u
      Timecop.travel 2.hours
      assert_equal 1, u.wins_today.size
      Timecop.freeze(1.day.from_now.beginning_of_day) do
        assert_equal 0, u.wins_today.size, "wins should reset at beginning of each day"
      end
    end
  end
  
  test "already won auction of same product" do
    Timecop.freeze do      
      u = Factory :account, :credits => 5
      a = Factory :auction
      a2 = Factory :auction, :product => a.product
      assert_bid u, a
      Timecop.travel 2.hours
      assert u.already_won?(a2)
      assert_no_bid u, a2, "Shouldn't be able to bid on same product already won"
    end
  end
  
  test "usernames are alphanumeric" do
    x = ->(name) {Factory.build(:account, :username => name).invalid?}
    assert x.call("Larry.Bean")
    assert x.call("Larry Bean")
    assert x.call("Larry_7")
    assert !x.call("grapes2")
  end
  
  test "beginner?" do
    u = Factory :account, :credits => 5
    assert u.beginner?
    assert_bid u
    Timecop.travel 2.hours
    assert !u.reload.beginner?, "not a beginner, already won"
  end
  
  test "awarding bids increments cumulative bids too" do
    u = Factory.build :account, :credits => 0, :bonuses => 0
    x = u.award :credits, 5
    assert_equal u, x, "should return self"
    assert_equal 5, u.credits
    assert_equal 5, u.cumulative_credits
    u.award :bonuses, 3
    assert_equal 3, u.bonuses
    assert_equal 3, u.cumulative_bonuses
  end
  
  test "active bots" do
    Timecop.freeze do
      u = Factory :account, :credits => 5
      bot = Factory :bid_bot, :account => u
      assert_equal 1, u.active_bots.size
      Timecop.travel 2.hours
      assert_equal 0, u.active_bots.size
    end
  end

end
