require 'test_helper'

class ActivationsControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
  test "nonexistant accounts get redirected" do
    get :new
    assert_response :redirect
    assert_equal I18n.t("flash.activations.account_not_found"), flash.alert
    get :new, {:code => "invalid"}
    assert_response :redirect
    assert_equal I18n.t("flash.activations.account_not_found"), flash.alert
  end
  
  test "already verified accounts get redirected" do
    a = Factory :account
    a.activate
    get :new, {:code => a.single_access_token}
    assert_response :redirect
    assert_equal I18n.t("flash.activations.already_verified"), flash.alert
  end
  
  test "found account gets activated" do
    a = Factory :account
    assert !a.verified?, "new accounts shouldn't be already verified"
    get :new, {:code => a.single_access_token}
    assert_response :redirect
    assert a.reload.verified?, "should have been verified"
    assert_equal I18n.t("flash.activations.activated"), flash.notice
  end
  
  test "can't request activation if verified" do
    a = Factory :account
    a.activate
    AccountSession.create a
    post :create
    assert_response :redirect, @response.body
    assert_equal I18n.t("flash.activations.already_verified"), flash.alert
  end
  
  test "can request activation" do
    a = Factory :account
    AccountSession.create a
    post :create
    assert_response :redirect, @response.body
    assert_equal I18n.t("flash.activations.created"), flash.notice
  end
  
end
