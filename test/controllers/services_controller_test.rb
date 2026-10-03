require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  test "index lists visible services and hides inactive ones" do
    get services_url
    assert_response :success
    assert_match "État civil", response.body
    assert_no_match "Service fermé", response.body
  end

  test "index shows the emergency panel" do
    get services_url
    assert_response :success
    assert_select "#emergency-heading"
  end

  test "search filters the catalog" do
    get services_url, params: { q: "civil" }
    assert_response :success
    assert_match "État civil", response.body
    assert_no_match(/Santé<\/a>/o, response.body)
  end

  test "show renders a service by its slug" do
    get service_url(services(:etat_civil))
    assert_response :success
    assert_match "Hôtel de Ville", response.body
    assert_select "[data-controller='map']"
  end

  test "maintenance services expose their status" do
    get service_url(services(:water_maintenance))
    assert_response :success
    assert_select ".alert"
  end

  test "inactive services are not found" do
    get service_url("ferme")
    assert_response :not_found
  end
end
