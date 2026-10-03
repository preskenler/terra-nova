require "test_helper"

module Agents
  class SecurityEventsControllerTest < ActionDispatch::IntegrationTest
    test "regular agents cannot read security events" do
      sign_in agents(:agent)
      get agents_security_events_url
      assert_response :redirect
    end

    test "administrators can read security events" do
      sign_in agents(:admin)
      get agents_security_events_url
      assert_response :success
    end
  end
end
