require 'test_helper'

class AuctionTest < ActiveSupport::TestCase
  
  def setup
    Auction.destroy_all
  end
  
  test "do not show beginner auctions in history" do    
    assert_no_difference 'Auction.history.size' do
      a = Factory :auction, :beginner => true
      finish a
    end
  end
  
  test "beginner auctions only visible to logged in customers who haven't won anything" do
    u = Factory :account, :credits => 1
    a = Factory :auction, :beginner => true
    a2 = Factory :auction, :beginner => true, :ending_in => 5.hours
    assert Auction.for_user(nil).empty?, "not logged in, shouldnt see them"
    assert Auction.for_user(u).present?, "beginner should see beginner auctions"
    assert_bid u, a
    finish a
    assert !u.reload.beginner?, "no longer beginner"
    assert Auction.for_user(u).reload.empty?, "not a beginner anymore. shouldn't see this"
  end
  
  test "buy now price starts at retail" do
    u1 = Factory :account, :credits => 10
    a = Factory :auction, :is_buy_now => true
    assert_equal a.retail_price, a.buy_now_price(u1)
  end
  
  test "bonus bids do not affect buy now price" do
    u = Factory :account, :credits => 10, :bonuses => 2
    a = Factory :auction, :is_buy_now => true
    assert_no_difference "a.reload.buy_now_price(u)" do
      assert_bid u, a
    end
  end
  
  test "buy now price decreases by bid price" do
    u = Factory :account, :credits => 10
    a = Factory :auction, :is_buy_now => true
    assert_difference("a.reload.buy_now_price(u.reload)", Money.new(-75)) do
      bid!(u, a)
    end
  end
  
end
