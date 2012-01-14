require 'test_helper'

class Admin::OrdersControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
  def setup
    @b = Factory.build :bid_order
  end
  
  test "refunding an order" do
    @b.capture!
    put :refund, :id => @b.id
    assert_equal "refunded", @b.reload.state
    assert_redirected_to admin_orders_url
  end
  
end
