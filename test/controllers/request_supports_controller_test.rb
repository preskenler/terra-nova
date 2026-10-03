require "test_helper"

class RequestSupportsControllerTest < ActionDispatch::IntegrationTest
  test "a citizen can support a request" do
    sign_in users(:citizen)

    assert_difference -> { RequestSupport.count }, 1 do
      post request_support_url(requests(:pothole))
    end

    assert_redirected_to request_url(requests(:pothole))
  end

  test "a citizen can withdraw their support" do
    sign_in users(:admin)

    assert_difference -> { RequestSupport.count }, -1 do
      delete request_support_url(requests(:streetlight))
    end
  end
end
