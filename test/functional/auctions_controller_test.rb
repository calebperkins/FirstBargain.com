require 'test_helper'

class AuctionsControllerTest < ActionController::TestCase
  
  # If this fails you need to seed the test database beforehand
  test "homepage" do
    get :index
    assert_response :success, @response.body
  end
  
  test "auction details" do
    a = Factory :auction
    get :show, :id => a.id
    assert_response :success, @response.body
  end
  
end
