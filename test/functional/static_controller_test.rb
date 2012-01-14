require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  
  test "all pages return 200" do
    [:privacy, :faq, :about, :tos, :returns, :rewards, :guarantee, :tips].each do |page|
      get page
      assert_response :success
    end
  end
  
end
