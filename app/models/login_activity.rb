# frozen_string_literal: true

# A recorded sign-in, used to detect and report sign-ins from a new device (F54).
class LoginActivity < ApplicationRecord
  belongs_to :user

  scope :recent_first, -> { order(created_at: :desc) }

  # Records a sign-in and notifies the citizen when the device is new.
  # Called from a Warden after-authentication hook.
  def self.record!(user:, request:)
    return if request.blank?

    ip = request.remote_ip
    user_agent = request.user_agent.to_s
    fingerprint = Digest::SHA256.hexdigest("#{ip}|#{user_agent}")
    known_device = user.login_activities.where(fingerprint: fingerprint).exists?
    had_previous = user.login_activities.exists?

    user.login_activities.create!(ip: ip, user_agent: user_agent.first(255), fingerprint: fingerprint)

    # First ever sign-in or already-known device: nothing to report.
    return if known_device || !had_previous

    user.notifications.create!(
      kind: "general",
      notifiable: user,
      title: I18n.t("notifications.new_device.title"),
      body: I18n.t("notifications.new_device.body", ip: ip)
    )
    UserMailer.new_sign_in(user, ip: ip, user_agent: user_agent).deliver_later
  end

  def device_label
    return I18n.t("account.devices.unknown") if user_agent.blank?

    user_agent.first(80)
  end
end
