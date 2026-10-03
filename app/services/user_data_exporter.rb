# frozen_string_literal: true

# Builds a clear, structured export of everything Nova Terra holds about a
# citizen (F55). The result is deliberately readable rather than raw dumps.
class UserDataExporter
  def initialize(user)
    @user = user
  end

  def as_json
    {
      exported_at: Time.current.iso8601,
      application: "Nova Terra",
      account: account,
      profile: profile,
      requests: requests,
      appointments: appointments,
      notifications: notifications,
      messages: messages,
      supports: supports
    }
  end

  private

  def account
    {
      email: @user.email,
      role: @user.role,
      language: @user.locale,
      high_contrast: @user.high_contrast,
      large_text: @user.large_text,
      reduced_data: @user.reduced_data,
      two_factor_enabled: @user.otp_enabled?,
      registered_at: @user.created_at.iso8601,
      last_sign_in_at: @user.last_sign_in_at&.iso8601
    }
  end

  def profile
    profile = @user.profile
    return {} if profile.blank?

    {
      address: profile.address,
      postal_code: profile.postal_code,
      city: profile.city,
      phone: profile.phone
    }
  end

  def requests
    @user.requests.recent_first.map do |request|
      {
        reference: request.reference,
        subject: request.subject,
        description: request.description,
        status: request.status,
        service: request.service&.name,
        location: request.location_text,
        submitted_at: request.created_at.iso8601,
        steps: request.request_events.chronological.map do |event|
          { status: event.to_status, comment: event.comment, at: event.created_at.iso8601 }
        end
      }
    end
  end

  def appointments
    @user.appointments.recent_first.map do |appointment|
      {
        starts_at: appointment.starts_at.iso8601,
        status: appointment.status,
        agent: appointment.agent.email,
        service: appointment.service&.name,
        notes: appointment.notes
      }
    end
  end

  def notifications
    @user.notifications.recent_first.map do |notification|
      { title: notification.title, body: notification.body, read: notification.read?, at: notification.created_at.iso8601 }
    end
  end

  def messages
    @user.feedbacks.recent_first.map do |feedback|
      { reference: feedback.reference, subject: feedback.subject, status: feedback.status, at: feedback.created_at.iso8601 }
    end
  end

  def supports
    @user.request_supports.includes(:request).map do |support|
      { request: support.request.reference, at: support.created_at.iso8601 }
    end
  end
end
