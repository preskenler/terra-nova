require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "transparency page renders" do
    get transparency_url
    assert_response :success
    assert_match "Transparence", response.body
  end

  test "accessibility page renders" do
    get accessibility_url
    assert_response :success
    assert_match "Accessibilité", response.body
  end

  test "eco page renders with measured metrics" do
    get eco_url
    assert_response :success
    assert_match "Impact environnemental", response.body
  end
end
