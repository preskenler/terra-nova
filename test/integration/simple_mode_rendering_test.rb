require "test_helper"

class SimpleModeRenderingTest < ActionDispatch::IntegrationTest
  test "simple mode strips non-essential sections from the service page (F96)" do
    sign_in users(:citizen)
    user = users(:citizen)
    user.update!(simple_mode: true)

    get service_url(services(:etat_civil))

    assert_response :success
    # The review form and related-services blocks are hidden in simple mode.
    assert_no_match I18n.t("service_reviews.leave"), response.body
    assert_no_match I18n.t("services.related"), response.body
  end

  test "reduced-data mode skips the interactive map but keeps the address (F95)" do
    sign_in users(:citizen)
    users(:citizen).update!(reduced_data: true)

    get service_url(services(:etat_civil))

    assert_response :success
    assert_no_match(/data-controller="map"/, response.body)
    assert_match "Hôtel de Ville", response.body
  end
end
