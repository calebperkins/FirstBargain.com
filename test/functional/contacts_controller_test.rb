require 'test_helper'

class ContactsControllerTest < ActionController::TestCase
  
  test "get to new contact page" do
    get :show
    assert_response :success
    assert_not_nil :contact
  end
  
  test "good contact sends email and redirects to home" do
    post :create, :contact => Factory.attributes_for(:contact)
    assert_redirected_to root_url
  end
  
  test "bad contact renders show" do
    post :create, :contact => Factory.attributes_for(:contact, :email => "")
    assert_response :success
    assert_template :show
    assert_not_nil :contact
  end
  
end
