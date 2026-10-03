require "test_helper"

class PartnersControllerTest < ActionDispatch::IntegrationTest
  test "index lists published partners and hides drafts" do
    get partners_url
    assert_response :success
    assert_match "Centre Horizon", response.body
    assert_no_match "Brouillon", response.body
  end

  test "show renders a partner with its opening hours" do
    get partner_url(partners(:health))
    assert_response :success
    assert_match "08:30", response.body
  end
end
