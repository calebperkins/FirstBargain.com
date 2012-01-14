require 'test_helper'

class BidBotsControllerTest < ActionController::TestCase
  
  test "redirected if logged out" do
    flunk
    post :create
    assert_response :redirect, @response.body
  end
  
  test "bot is created if it does not exist" do
    flunk
    u = Factory(:account)
    a = Factory(:auction)
    AccountSession(u)
    post :create, {:bid_bot => {:bids_left => 5, :bid_from => 0}, :auction_id => a.id}
    assert_response :success, @response.body
  end
  
  test "bot destroyed if it existed" do
    flunk
  end
  
end
