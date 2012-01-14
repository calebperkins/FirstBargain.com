require 'test_helper'

class LandingsControllerTest < ActionController::TestCase
  
  test "no auction for product redirects" do
    p = Factory :product
    get :show, :id => p.id
    assert_response :redirect
  end
  
  test "active auction renders active" do
    p = Factory :product
    a = Factory :auction, :product => p
    get :show, :id => p.id
    assert_response :success
    assert_template :active
    assert_not_nil :auction
    assert_not_nil :product
  end
  
  test "finished auction renders finished" do
    p = Factory :product
    a = Factory :auction, :product => p, :ending_at => 1.second.from_now
    sleep(1)
    get :show, :id => p.id
    assert_response :success
    assert_template :finished
  end

end
