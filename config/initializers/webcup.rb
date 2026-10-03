# Configuration for the external Webcup "Terra Nova" API.
#
# The API key is server-side only: it is never rendered into HTML/JS. In
# development/test it can come from the environment; in production prefer Rails
# encrypted credentials (`bin/rails credentials:edit`, key `webcup.api_key`).
Rails.application.configure do
  config.x.webcup.base_url =
    ENV.fetch("WEBCUP_API_BASE_URL", "https://24h.webcup.fr/wp-json/webcup/v1")
  config.x.webcup.api_key =
    ENV["WEBCUP_API_KEY"].presence ||
    Rails.application.credentials.dig(:webcup, :api_key)
  config.x.webcup.poll_interval = ENV.fetch("WEBCUP_POLL_INTERVAL", 30).to_i
end
