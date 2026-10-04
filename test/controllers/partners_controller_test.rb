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

  test "index and show expose availability and the next step (F99)" do
    partners(:health).update!(available: false, next_action_fr: "Réouverture lundi.")

    get partners_url
    assert_response :success
    assert_match I18n.t("partners.unavailable"), response.body

    get partner_url(partners(:health))
    assert_response :success
    assert_match I18n.t("partners.next_action"), response.body
    assert_match "Réouverture lundi.", response.body
  end
end
