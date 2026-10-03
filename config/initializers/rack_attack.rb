# frozen_string_literal: true

# Rate limiting and brute-force protection.
# https://github.com/rack/rack-attack
class Rack::Attack
  ### Cache ###
  # A per-process memory store is fine for a single-node deployment. For
  # multi-node setups configure a shared store (Solid Cache, Redis...).
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new(
    expires_in: 1.hour, size: 5.megabytes
  )

  ### Safelists ###
  safelist("allow health checks") do |req|
    req.path == "/up"
  end

  safelist("allow localhost in development") do |req|
    Rails.env.development? && %w[127.0.0.1 ::1].include?(req.ip)
  end

  ### Throttles ###

  # Brute force: limit sign-in attempts per IP and per account.
  throttle("logins/ip", limit: 10, period: 5.minutes) do |req|
    req.ip if req.post? && req.path.include?("sign_in")
  end

  throttle("logins/email", limit: 5, period: 5.minutes) do |req|
    next unless req.post? && req.path.include?("sign_in")

    email = req.params.dig("user", "email") || req.params.dig("agent", "email")
    email.presence&.downcase
  end

  # Password reset abuse.
  throttle("password_resets/ip", limit: 5, period: 30.minutes) do |req|
    req.ip if req.post? && req.path.include?("password")
  end

  # Citizen request creation.
  throttle("requests/ip", limit: 20, period: 10.minutes) do |req|
    req.ip if req.post? && req.path == "/requests"
  end

  # Contact form and account creation abuse (F81).
  throttle("feedbacks/ip", limit: 10, period: 10.minutes) do |req|
    req.ip if req.post? && req.path == "/feedback"
  end

  throttle("signups/ip", limit: 10, period: 1.hour) do |req|
    req.ip if req.post? && req.path == "/users"
  end

  # Manual Webcup API refreshes from the agent console.
  throttle("webcup_refresh/ip", limit: 12, period: 1.minute) do |req|
    req.ip if req.post? && req.path.include?("/agents/demands/refresh")
  end

  ### Response ###
  self.throttled_responder = lambda do |request|
    message = I18n.t(
      "form_protection.throttled",
      default: "Too many requests. Please try again later."
    )
    [ 429, { "Content-Type" => "text/html; charset=utf-8", "Retry-After" => "60" }, [ message ] ]
  end
end
