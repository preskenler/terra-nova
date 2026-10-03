# frozen_string_literal: true

# Records citizen sign-ins and reports sign-ins from a new device (F54).
Warden::Manager.after_authentication do |user, auth, _options|
  next unless user.is_a?(User)

  LoginActivity.record!(user: user, request: auth.request)
  SecurityEvent.log("sign_in", actor: user, request: auth.request)
rescue StandardError => e
  Rails.logger.warn("LoginActivity recording failed: #{e.class}: #{e.message}")
end

Warden::Manager.before_failure do |env, _options|
  SecurityEvent.log("sign_in_failed", request: ActionDispatch::Request.new(env))
rescue StandardError => e
  Rails.logger.warn("SecurityEvent recording failed: #{e.class}: #{e.message}")
end
