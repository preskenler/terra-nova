require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "homepage renders in French by default" do
    get root_url
    assert_response :success
    assert_match "Bienvenue à Nova Terra", response.body
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
end
