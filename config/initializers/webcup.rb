# Configuration for the external Webcup "Terra Nova" API.
#
# The API key is server-side only: it is never rendered into HTML/JS. In
# development/test it can come from the environment; in production prefer Rails
# encrypted credentials (`bin/rails credentials:edit`, key `webcup.api_key`).
#
# Reading credentials requires the master key. If `RAILS_MASTER_KEY` is missing
# or wrong (a common first-deploy mistake on shared hosting), decryption raises
# and would abort boot, taking the whole site down with a bare Apache 500. We
# treat that as "API not configured" instead: the demand feed degrades but the
# rest of the platform keeps working.
webcup_api_key = ENV["WEBCUP_API_KEY"].presence

begin
  webcup_api_key ||= Rails.application.credentials.dig(:webcup, :api_key)
rescue StandardError => e
  warn "[webcup] could not read encrypted credentials (#{e.class}). " \
       "Set RAILS_MASTER_KEY on the server, or provide WEBCUP_API_KEY, to " \
       "enable the Terra Nova demand feed."
end

Rails.application.configure do
  config.x.webcup.base_url =
    ENV.fetch("WEBCUP_API_BASE_URL", "https://24h.webcup.fr/wp-json/webcup/v1")
  config.x.webcup.api_key = webcup_api_key
  config.x.webcup.poll_interval = ENV.fetch("WEBCUP_POLL_INTERVAL", 30).to_i
end
