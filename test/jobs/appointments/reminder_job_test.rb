require "test_helper"

module Appointments
  class ReminderJobTest < ActiveSupport::TestCase
    test "sends a reminder for appointments happening in about 24 hours" do
      appointment = appointments(:upcoming)
      appointment.update_columns(
        starts_at: 24.hours.from_now, ends_at: 24.hours.from_now + 30.minutes,
        status: "confirmed", reminder_sent_at: nil
      )

      assert_enqueued_emails 1 do
        Appointments::ReminderJob.new.perform
      end

      assert appointment.reload.reminder_sent_at.present?
    end

    test "does not remind twice" do
      appointment = appointments(:upcoming)
      appointment.update_columns(
        starts_at: 24.hours.from_now, ends_at: 24.hours.from_now + 30.minutes,
        status: "confirmed", reminder_sent_at: Time.current
      )

      assert_no_enqueued_emails do
        Appointments::ReminderJob.new.perform
      end
    end
  end
end
