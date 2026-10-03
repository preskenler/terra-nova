# frozen_string_literal: true

class AppointmentMailer < ApplicationMailer
  # Confirmation sent when an appointment is booked (F39).
  def confirmation(appointment)
    @appointment = appointment
    @user = appointment.user
    mail(
      to: @user.email,
      subject: t("appointment_mailer.confirmation.subject", date: l(appointment.starts_at, format: :short))
    )
  end

  # Reminder sent before the appointment (F40).
  def reminder(appointment)
    @appointment = appointment
    @user = appointment.user
    mail(
      to: @user.email,
      subject: t("appointment_mailer.reminder.subject", date: l(appointment.starts_at, format: :short))
    )
  end
end
