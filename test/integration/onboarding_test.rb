require "test_helper"

class OnboardingTest < ActionDispatch::IntegrationTest
  test "a newcomer is redirected to onboarding from the personal space" do
    sign_in users(:newcomer)
    get citizen_dashboard_url
    assert_redirected_to onboarding_url
  end

  test "an onboarded citizen reaches the personal space" do
    sign_in users(:citizen)
    get citizen_dashboard_url
    assert_response :success
  end

  test "completing onboarding marks the account and lands in the space" do
    sign_in users(:newcomer)

    patch onboarding_url, params: {
      profile: { address: "12 rue des Étoiles", city: "Nova Terra", phone: "0102030405" },
      user: { locale: "en", high_contrast: "1" }
    }

    assert_redirected_to citizen_dashboard_url
    user = users(:newcomer).reload
    assert user.onboarding_completed?
    assert_equal "en", user.locale
    assert user.high_contrast?
    assert_equal "12 rue des Étoiles", user.profile.address
  end

  test "signing up sends a new citizen to onboarding" do
    assert_difference -> { User.count }, 1 do
      post user_registration_url, params: {
        user: {
          email: "nouvelle@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to onboarding_url
    assert User.find_by(email: "nouvelle@example.com").profile.present?
  end
end
