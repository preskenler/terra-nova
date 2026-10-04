require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "homepage renders in French by default" do
    get root_url
    assert_response :success
    assert_match "Bienvenue à Terra Nova", response.body
  end

  test "homepage sets the document language" do
    get root_url
    assert_select "html[lang=?]", "fr"
  end

  test "homepage exposes the skip link and main landmark" do
    get root_url
    assert_select "a[href=?]", "#main-content"
    assert_select "main#main-content"
  end

  test "homepage does not preload the map library (F61)" do
    get root_url
    assert_no_match(/modulepreload[^>]*leaflet/, response.body)
  end

  test "the public header uses the grouped megamenu" do
    get root_url

    assert_select "div.megamenu#public-menu"
    assert_select "div#public-menu button[popovertarget=?]", "public-menu-discover"
    assert_select "div#public-menu-discover li a", text: I18n.t("nav.services")
  end
end
