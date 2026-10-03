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
  end
end
