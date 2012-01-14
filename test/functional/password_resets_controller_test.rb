require 'test_helper'

class PasswordResetsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
  test "request a password reset with a valid account" do
    x = Factory :account
    post :create, :email => x.email
    assert_response :redirect, @response.body
    assert_not_nil flash.notice, flash.inspect
  end
  
  test "request a password reset with an invalid account" do
    post :create, :email => "fake@fake.com"
    assert_response :success, @response.body
    assert_template :new
    assert_equal I18n.t("flash.password_reset.no_account"), flash.alert
  end
  
  test "get to password change screen with good code" do
    x = Factory :account
    get :edit, :code => x.perishable_token
    assert_response :success, @response.body
  end
  
  test "redirect if code is bad" do
    get :edit, :code => "invalid"
    assert_response :redirect, @response.body
  end
  
  test "update password" do
    x = Factory :account
    put :update, :code => x.perishable_token, :account => {:password => "foobar", :password_confirmation => "foobar"}
    assert_equal x.password, "foobar"
    assert_response :redirect, @response.body
  end
  
end
