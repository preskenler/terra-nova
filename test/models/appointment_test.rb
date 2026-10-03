require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  test "computes ends_at from the start and duration" do
    start = 5.days.from_now.change(hour: 10, min: 0)
    appointment = agents(:agent).appointments.new(
      user: users(:citizen), starts_at: start, duration_minutes: 45
    )
    appointment.validate
    assert_equal start + 45.minutes, appointment.ends_at
  end

  test "rejects overlapping appointments for the same agent" do
    start = 5.days.from_now.change(hour: 10, min: 0)
    agents(:agent).appointments.create!(user: users(:citizen), starts_at: start, duration_minutes: 30)

    duplicate = agents(:agent).appointments.new(
      user: users(:admin), starts_at: start + 10.minutes, duration_minutes: 30
    )

    assert_not duplicate.valid?
    assert duplicate.errors[:starts_at].any?
  end

  test "upcoming scope only returns future appointments" do
    references = Appointment.upcoming.map(&:id)
    assert_includes references, appointments(:upcoming).id
    assert_not_includes references, appointments(:past).id
  end
end
