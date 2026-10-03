require "test_helper"

class PreferencesControllerTest < ActionDispatch::IntegrationTest
  test "storing display preferences applies the accessibility attributes" do
    patch preferences_url, params: { high_contrast: "1", large_text: "1" }
    assert_response :redirect

    get root_url
    assert_select "html[data-theme=?]", "contrast"
    assert_select "html.large-text"
  end
end
