require "test_helper"

module Agents
  class AppointmentsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot access the agent schedule" do
      sign_in users(:citizen)
      get agents_appointments_url
      assert_response :redirect
    end

    test "an agent lists their appointments" do
      sign_in agents(:agent)
      get agents_appointments_url
      assert_response :success
      assert_match appointments(:upcoming).user.email, response.body
    end

    test "cancelling notifies the citizen" do
      sign_in agents(:agent)
      appointment = appointments(:upcoming)

      assert_difference -> { appointment.user.notifications.count }, 1 do
        patch cancel_agents_appointment_url(appointment)
      end

      assert_equal "cancelled", appointment.reload.status
    end

    test "an agent can reschedule an appointment" do
      sign_in agents(:agent)
      appointment = appointments(:upcoming)
      new_start = appointment.starts_at + 1.day

      patch agents_appointment_url(appointment), params: { appointment: { starts_at: new_start.iso8601 } }

      assert_redirected_to agents_appointment_url(appointment)
      assert_equal new_start.to_i, appointment.reload.starts_at.to_i
    end
  end
end
