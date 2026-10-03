require "test_helper"

class TransportsControllerTest < ActionDispatch::IntegrationTest
  test "index lists active lines" do
    get transports_url
    assert_response :success
    assert_match "Tram T1", response.body
    assert_match "Bus B2", response.body
  end
end
