require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "the personal data page renders" do
    sign_in users(:citizen)
    get data_account_url
    assert_response :success
  end

  test "personal data can be exported as JSON" do
    sign_in users(:citizen)
    get export_account_url

    assert_response :success
    assert_includes response.media_type, "json"
    assert_match "NOVA-2026-AAAAA", response.body
  end
end
