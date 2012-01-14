require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  test "searching orders in admin" do
    Order.destroy_all
    a = Factory :account
    5.times {Factory :bid_order, :state => "complete", :account => a}
    2.times {Factory :bid_order, :state => "refunded"}
    assert_equal 5, Order.search(:complete).size
    assert_equal 2, Order.search(:refunded).size
    assert_equal 5, Order.search(:complete, a.username).size
    assert_equal 0, Order.search(:refunded, a.username).size
  end

end