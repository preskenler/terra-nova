require "test_helper"

module Users
  class MagicLinksControllerTest < ActionDispatch::IntegrationTest
    test "requesting a link for a known email enqueues an email" do
      assert_enqueued_emails 1 do
        post users_magic_link_url, params: { email: users(:citizen).email }
      end

      assert_redirected_to new_user_session_url
    end

    test "requesting a link for an unknown email stays silent" do
      assert_no_enqueued_emails do
        post users_magic_link_url, params: { email: "nobody@example.com" }
      end

      assert_redirected_to new_user_session_url
    end

    test "consuming a valid link signs the citizen in" do
      token = Users::MagicLink.generate(users(:citizen))

      get users_magic_link_session_url(token: token)

      assert_redirected_to citizen_dashboard_url
    end

    test "an invalid link is rejected" do
      get users_magic_link_session_url(token: "nonsense")

      assert_redirected_to new_user_session_url
    end
  end
end
