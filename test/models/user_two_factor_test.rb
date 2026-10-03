require "test_helper"

class UserTwoFactorTest < ActiveSupport::TestCase
  RequestDouble = Struct.new(:remote_ip, :user_agent)

  test "generates a secret and verifies a valid code" do
    user = users(:citizen)
    user.generate_otp_secret!
    assert user.otp_secret.present?
    assert user.verify_otp(ROTP::TOTP.new(user.otp_secret).now)
    assert_not user.verify_otp("000000")
  end

  test "enable and disable toggles otp_enabled?" do
    user = users(:citizen)
    user.generate_otp_secret!
    user.enable_two_factor!
    assert user.otp_enabled?

    user.disable_two_factor!
    assert_not user.otp_enabled?
    assert_nil user.otp_secret
  end
end
