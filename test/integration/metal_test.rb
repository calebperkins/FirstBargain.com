require 'test_helper'

class MetalTest < ActionDispatch::IntegrationTest
  
  def setup
    5.times {Factory :auction}
  end

  test "get widget" do
   # get "/promos/init", :auctions => "[]", :widgets => "[]", :callback => "function123"
  #assert_response :success
    get "/promos/#{Auction.last.id}", :t => 123456789
    assert_response :success
  end
  
  test "get poll" do
    ids = Auction.all.collect(&:id)
    get "/poller", :ids => ids.join("-"), :u => "null", :t => 123456789
    assert_response :success
    get "/poller/#{ids.first}", :u => "null", :t => 123456789
    assert_response :success
  end
  
end
