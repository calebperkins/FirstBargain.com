require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  
  test "blank orders should redirect" do
    get :index
    assert_response :redirect, @response.body
  end
  
end
