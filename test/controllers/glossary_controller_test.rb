require "test_helper"

class GlossaryControllerTest < ActionDispatch::IntegrationTest
  test "index lists glossary terms" do
    get glossary_url
    assert_response :success
    assert_match "Signalement", response.body
    assert_match "Prévenir la ville", response.body
  end
end
