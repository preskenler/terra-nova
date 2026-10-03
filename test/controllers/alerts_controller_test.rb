require "test_helper"

class AlertsControllerTest < ActionDispatch::IntegrationTest
  test "index lists active alerts" do
    get alerts_url
    assert_response :success
    assert_match "Montée des eaux", response.body
    assert_no_match "Ancienne alerte", response.body
  end
end
