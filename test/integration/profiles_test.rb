require "test_helper"

class ProfilesTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get profile_url
    assert_response :redirect
  end

  test "a citizen can view and update their profile" do
    sign_in users(:citizen)

    get profile_url
    assert_response :success

    patch profile_url, params: {
      profile: { address: "1 place de la Mairie", city: "Nova Terra", phone: "0601020304" },
      user: { locale: "fr", large_text: "1" }
    }

    assert_redirected_to profile_url
    user = users(:citizen).reload
    assert_equal "1 place de la Mairie", user.profile.address
    assert user.large_text?
  end
end
