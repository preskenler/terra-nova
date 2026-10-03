require "test_helper"

class LocalesControllerTest < ActionDispatch::IntegrationTest
  test "switching to English persists in the session" do
    patch locale_url, params: { locale: "en" }
    assert_response :redirect

    get root_url
    assert_match "Welcome to Nova Terra", response.body
    assert_select "html[lang=?]", "en"
  end

  test "an unsupported locale is ignored" do
    patch locale_url, params: { locale: "xx" }
    get root_url
    assert_select "html[lang=?]", "fr"
  end
end
