require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get appointments_url
    assert_response :redirect
  end

  test "the booking form renders available slots" do
    sign_in users(:citizen)
    get new_appointment_url(agent_id: agents(:agent).id, date: next_monday)
    assert_response :success
  end

  test "booking confirms the appointment, notifies and emails the citizen" do
    sign_in users(:citizen)
    agent = agents(:agent)
    slot = Appointments::AvailableSlots.new(agent: agent, date: next_monday).call.first

    assert_difference -> { Appointment.count }, 1 do
      assert_enqueued_emails 1 do
        assert_difference -> { users(:citizen).notifications.count }, 1 do
          post appointments_url, params: {
            appointment: { agent_id: agent.id, starts_at: slot.iso8601 }
          }
        end
      end
    end

    appointment = Appointment.last
    assert_redirected_to appointment_url(appointment)
    assert_equal "confirmed", appointment.status
  end

  test "a citizen can cancel their appointment" do
    sign_in users(:citizen)
    appointment = appointments(:upcoming)

    patch cancel_appointment_url(appointment)

    assert_redirected_to appointment_url(appointment)
    assert_equal "cancelled", appointment.reload.status
  end
end
