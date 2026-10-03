require "test_helper"

module Agents
  class AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot manage agent availability" do
      sign_in users(:citizen)
      get agents_availabilities_url
      assert_response :redirect
    end

    test "an agent views their availability" do
      sign_in agents(:agent)
      get agents_availabilities_url
      assert_response :success
    end

    test "an agent adds and removes an availability" do
      sign_in agents(:agent)

      assert_difference -> { AgentAvailability.count }, 1 do
        post agents_availabilities_url, params: {
          agent_availability: { wday: 2, start_time: "08:00", end_time: "10:00", slot_minutes: 30 }
        }
      end
      assert_redirected_to agents_availabilities_url

      availability = AgentAvailability.order(:created_at).last
      assert_difference -> { AgentAvailability.count }, -1 do
        delete agents_availability_url(availability)
      end
    end
  end
end
