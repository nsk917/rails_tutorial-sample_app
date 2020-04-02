require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @activated = users(:michael)
    @non_activated = users(:orn)
  end

  test "should not redirect show when activated user" do
    log_in_as(@activated)
    get user_path(@activated.id)
    assert_response :success
  end

  test "should redirect show when non-activated user" do
    log_in_as(@activated)
    get user_path(@non_activated.id)
    assert_redirected_to root_url
  end
end