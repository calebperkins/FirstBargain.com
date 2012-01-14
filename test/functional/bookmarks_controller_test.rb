require 'test_helper'

class BookmarksControllerTest < ActionController::TestCase
  setup :activate_authlogic
  
  test "watch a new auction and existing auction" do
    u = Factory :account
    a = Factory :auction
    AccountSession.create u
    2.times do
      post :create, :auction_id => a.id
      assert_response :redirect
      assert_redirected_to bookmarks_url
    end
  end
  
  test "delete an existing auction and bogus auction" do
    u = Factory :account
    a = Factory :auction
    AccountSession.create u
    b = Bookmark.create :account => u, :auction => a
    delete :destroy, :id => a.id
    assert_redirected_to bookmarks_url
  end
  
end
