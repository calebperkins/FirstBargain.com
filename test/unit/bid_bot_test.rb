require 'test_helper'

class BidBotTest < ActiveSupport::TestCase

  def setup
    @user = Factory :account, :credits => 10
  end

  test "only one bid bot per user, per auction" do
    bot = Factory :bid_bot, :account => @user
    assert_raise ActiveRecord::RecordInvalid do # replace with RecordNotUnique once we allow > 1 active bots
      Factory :bid_bot, :auction => bot.auction, :account => bot.account
    end
  end

  test "bids left always >= 0" do
    assert_raise ActiveRecord::RecordInvalid do
      Factory :bid_bot, :bids_left => -1, :account => @user
    end
  end

  test "bid from always >= 0" do
    assert_raise ActiveRecord::RecordInvalid do
      Factory :bid_bot, :bid_from => -1.to_money, :account => @user
    end
  end

  test "using a bid bot decreases bids left" do
    bot = Factory :bid_bot, :account => @user
    assert_difference "bot.bids_left", -1 do
      bot.bid!
    end
  end

  test "Resque job performs a bid" do
    b = Factory :bid_bot, :account => @user, :bid_from_in_cents => 0
    assert_difference "b.auction.reload.going_price.cents", 1 do
      BidBot.perform(b.auction_id)
    end
  end

  test "bots count towards active auctions" do
    assert_difference("@user.active_auctions.size", 1) do
      Factory :bid_bot, :account => @user
    end
  end

  test "deleting unused bot decreases active auctions" do
    b = Factory :bid_bot, :account => @user
    assert_difference("@user.active_auctions.size", -1) do
      b.destroy
    end
  end
  
  test "only one active bot per user" do
    Factory :bid_bot, :account => @user
    assert_raise ActiveRecord::RecordInvalid do
      Factory :bid_bot, :account => @user
    end
  end
end
