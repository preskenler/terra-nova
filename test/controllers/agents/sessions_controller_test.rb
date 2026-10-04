require "test_helper"

module Agents
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test "an agent signing in lands in the agent workspace" do
      post agent_session_url, params: { agent: { email: agents(:agent).email, password: "password123" } }

      assert_redirected_to agents_root_url
    end

    test "signing out returns to the agent sign-in page" do
      sign_in agents(:agent)

      delete destroy_agent_session_url

      assert_redirected_to new_agent_session_url
    end
  end
end
