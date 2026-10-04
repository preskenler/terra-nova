require "test_helper"

module Agents
  class UsersControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access citizen account administration" do
      sign_in users(:citizen)
      get agents_users_url
      assert_response :redirect
    end

    test "an agent lists citizen accounts" do
      sign_in agents(:agent)
      get agents_users_url
      assert_response :success
      assert_match users(:citizen).email, response.body
    end

    test "an agent updates a citizen account" do
      sign_in agents(:agent)
      target = users(:citizen)

      patch agents_user_url(target), params: { user: { locale: "en", onboarding_completed: "1" } }

      assert_redirected_to agents_user_url(target)
      assert_equal "en", target.reload.locale
    end

    test "a regular agent cannot grant administrator rights" do
      sign_in agents(:agent)
      target = users(:citizen)

      patch agents_user_url(target), params: { user: { role: "admin" } }

      assert_equal "citizen", target.reload.role
    end

    test "an administrator agent can grant administrator rights" do
      sign_in agents(:admin)
      target = users(:citizen)

      patch agents_user_url(target), params: { user: { role: "admin" } }

      assert_equal "admin", target.reload.role
    end

    test "an agent can unlock a locked account" do
      sign_in agents(:agent)
      target = users(:citizen)
      target.update_columns(failed_attempts: 5, locked_at: Time.current)
      assert target.reload.access_locked?

      patch unlock_agents_user_url(target)

      assert_redirected_to agents_user_url(target)
      assert_not target.reload.access_locked?
    end

    test "an agent can create a citizen account without an email (F71)" do
      sign_in agents(:agent)

      assert_difference -> { User.count }, 1 do
        post agents_users_url, params: { user: { locale: "fr" } }
      end

      user = User.order(:created_at).last
      assert user.login_id.present?
      assert_equal "citizen", user.role
      assert_redirected_to agents_user_url(user)
    end

    test "an agent can create a citizen account with an email" do
      sign_in agents(:agent)

      assert_difference -> { User.count }, 1 do
        post agents_users_url, params: { user: { email: "newresident@example.com", locale: "fr" } }
      end

      assert User.find_by(email: "newresident@example.com").login_id.present?
    end

    test "an agent views and edits a citizen account" do
      sign_in agents(:agent)
      target = users(:citizen)

      get agents_user_url(target)
      assert_response :success

      get edit_agents_user_url(target)
      assert_response :success
    end

    test "an invalid account creation re-renders the form" do
      sign_in agents(:agent)

      assert_no_difference -> { User.count } do
        post agents_users_url, params: { user: { email: "not-an-email", locale: "fr" } }
      end
      assert_response :unprocessable_content
    end
  end
end
