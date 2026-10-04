require "test_helper"

module Agents
  class TimeOffsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot manage time off" do
      sign_in users(:citizen)
      post agents_time_offs_url, params: { agent_time_off: { starts_at: 1.day.from_now, ends_at: 2.days.from_now } }
      assert_response :redirect
    end

    test "an agent creates and destroys a time off" do
      sign_in agents(:agent)

      assert_difference -> { AgentTimeOff.count }, 1 do
        post agents_time_offs_url, params: {
          agent_time_off: { starts_at: 3.weeks.from_now, ends_at: 3.weeks.from_now + 8.hours, reason: "Training" }
        }
      end
      assert_redirected_to agents_availabilities_url

      time_off = AgentTimeOff.order(:created_at).last
      assert_difference -> { AgentTimeOff.count }, -1 do
        delete agents_time_off_url(time_off)
      end
      assert_redirected_to agents_availabilities_url
    end

    test "an invalid time off is rejected" do
      sign_in agents(:agent)

      assert_no_difference -> { AgentTimeOff.count } do
        post agents_time_offs_url, params: {
          agent_time_off: { starts_at: 2.days.from_now, ends_at: 1.day.from_now, reason: "Bad" }
        }
      end
      assert_redirected_to agents_availabilities_url
      assert flash[:alert].present?
    end
  end
end
