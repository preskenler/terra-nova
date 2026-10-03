require "test_helper"

class TwoFactorSettingsControllerTest < ActionDispatch::IntegrationTest
  test "a citizen can enable and disable two-factor authentication" do
    user = users(:citizen)
    sign_in user

    get two_factor_settings_url
    assert_response :success

    post two_factor_settings_url, params: { code: ROTP::TOTP.new(user.reload.otp_secret).now }
    assert_redirected_to two_factor_settings_url
    assert user.reload.otp_enabled?

    delete two_factor_settings_url
    assert_not user.reload.otp_enabled?
  end
end
