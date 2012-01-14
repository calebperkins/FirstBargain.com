require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
  test "register page with referral cookies" do
    assert_logged_out
    get :new, :u => "lunatic"
    assert_response :success, @response.body
    assert_equal "lunatic", cookies["referral"]
  end
  
  test "registering with bad info" do
    post :create, :account => {:username => ""}
    assert_response :success, @response.body
    assert_template :create    
  end
  
  test "registering with good info" do
    post :create, :account => Factory.attributes_for(:account)
    assert_equal nil, cookies[:referral]
    assert_equal true, session[:welcome]
    assert_redirected_to welcome_account_url
  end
  
  test "account screen" do
    u = Factory :account
    AccountSession.create u
    get :show
    assert_response :success, @response.body
    assert_not_nil assigns(:winnings)
    assert_not_nil assigns(:wins)
    assert_not_nil assigns(:buynows)
  end
  
  test "account settings" do
    u = Factory :account
    AccountSession.create u
    get :edit
    assert_response :success, @response.body
    assert_template :edit
  end
  
end
