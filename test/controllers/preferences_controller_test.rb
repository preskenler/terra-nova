require "test_helper"

class PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "storing display preferences applies the accessibility attributes" do
    patch preferences_url, params: { high_contrast: "1", large_text: "1", reduced_data: "1" }
    assert_response :redirect

    get root_url
    assert_select "html[data-theme=?]", "contrast"
    assert_select "html.large-text"
  end

  test "low data mode removes the map from a service page" do
    sign_in users(:citizen)
    patch preferences_url, params: { reduced_data: "1" }

    get service_url(services(:etat_civil))
    assert_response :success
    assert_select "[data-controller='map']", count: 0
  end

  test "simple mode renders lighter pages (F62)" do
    patch preferences_url, params: { simple_mode: "1" }

    get root_url
    assert_no_match "Ce que vous pouvez faire", response.body

    get services_url
    assert_no_match "Services prioritaires", response.body
  end
end
