# frozen_string_literal: true

module Appointments
  # Sends a reminder for confirmed appointments happening in ~24 hours (F40).
  # Scheduled hourly via Solid Queue recurring tasks.
  class ReminderJob < ApplicationJob
    queue_as :default

    WINDOW = 25.hours

    def perform
      window = (Time.current + 23.hours)..(Time.current + WINDOW)

      Appointment.active.where(reminder_sent_at: nil, starts_at: window).find_each do |appointment|
        AppointmentMailer.reminder(appointment).deliver_later
        appointment.update_column(:reminder_sent_at, Time.current)
      end
    end
  end
end
