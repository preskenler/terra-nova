require "test_helper"

module Users
  class TwoFactorControllerTest < ActionDispatch::IntegrationTest
    test "the second factor gates the account until verified" do
      user = users(:citizen)
      user.update!(otp_required: true, otp_secret: ROTP::Base32.random)
      sign_in user

      get citizen_dashboard_url
      assert_redirected_to users_two_factor_url

      post users_two_factor_url, params: { code: ROTP::TOTP.new(user.otp_secret).now }
      assert_redirected_to citizen_dashboard_url

      get citizen_dashboard_url
      assert_response :success
    end

    test "a wrong code is rejected" do
      user = users(:citizen)
      user.update!(otp_required: true, otp_secret: ROTP::Base32.random)
      sign_in user

      post users_two_factor_url, params: { code: "000000" }
      assert_redirected_to users_two_factor_url
    end
  end
end
