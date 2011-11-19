require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get switchboard" do
    get :switchboard
    assert_response :success
  end

end
