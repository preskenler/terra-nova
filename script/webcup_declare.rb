# frozen_string_literal: true

# Submits the generated French feature declarations to the Webcup dashboard.
#
# The dashboard form is authenticated by a WordPress session cookie and a
# short-lived nonce. Both are read from the environment (see .env, git-ignored):
#
#   WEBCUP_ADMIN_COOKIE="wordpress_sec_...=...; wordpress_logged_in_...=..."
#
# The nonce is re-scraped from /dashboard/fonctionnalites/ on every run, so it
# is never hard-coded. The cookie expires regularly: refresh it from your
# browser when a run reports an auth failure.
#
# Usage:
#   ruby script/webcup_declare.rb                 # dry-run (default): show only
#   ruby script/webcup_declare.rb --only=D05,F91 # dry-run for a subset
#   ruby script/webcup_declare.rb --submit        # actually send everything
#   ruby script/webcup_declare.rb --submit --only=D05
#
# Requires Ruby (standard library only). Loads .env in development.
require "net/http"
require "json"
require "uri"
require "cgi"

ROOT = File.expand_path("..", __dir__)

# Minimal .env loader (no dependency): KEY=VALUE lines, ignores comments.
env_path = File.join(ROOT, ".env")
if File.exist?(env_path)
  File.foreach(env_path) do |line|
    next if line.strip.empty? || line.strip.start_with?("#")
    key, value = line.split("=", 2)
    next unless key && value
    ENV[key.strip] ||= value.strip.gsub(/\A["']|["']\z/, "")
  end
end

DASHBOARD_URL = "https://24h.webcup.fr/dashboard/fonctionnalites/"
POST_URL      = "https://24h.webcup.fr/wp-admin/admin-post.php"
REFERER       = "/dashboard/fonctionnalites/"
USER_AGENT    = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
                "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36"

args   = ARGV.dup
submit = args.delete("--submit")
only   = (args.find { |a| a.start_with?("--only=") } || "")[/--only=(.*)/, 1]
only   = only&.split(",")&.map(&:strip)

cookie = ENV["WEBCUP_ADMIN_COOKIE"].to_s
if cookie.empty?
  abort "WEBCUP_ADMIN_COOKIE is missing. Add it to your (git-ignored) .env file."
end

declarations = JSON.parse(File.read(File.join(ROOT, "tmp/webcup_declarations.json")))
declarations = declarations.select { |d| only.include?(d["id"]) } if only

puts "#{declarations.size} déclaration(s) à traiter#{submit ? " (ENVOI RÉEL)" : " (dry-run)"}."

def base_headers(cookie)
  {
    "Cookie" => cookie,
    "User-Agent" => USER_AGENT,
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language" => "fr-FR,fr;q=0.9,en;q=0.8"
  }
end

# 1. Fetch the dashboard to (a) check the session and (b) scrape the nonce.
def fetch_nonce(cookie)
  uri = URI(DASHBOARD_URL)
  req = Net::HTTP::Get.new(uri)
  base_headers(cookie).each { |k, v| req[k] = v }

  body = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req).body }
  if body.include?("wp-login.php") && !body.include?("webcup_v2_feature_nonce")
    abort "Session invalide : le cookie a expiré. Rafraîchis WEBCUP_ADMIN_COOKIE."
  end

  nonce = body[/name="webcup_v2_feature_nonce"\s+value="([^"]+)"/, 1]
  abort "Nonce introuvable dans le dashboard (session expirée ?)." if nonce.to_s.empty?
  nonce
end

def post_declaration(cookie, nonce, decl)
  uri = URI(POST_URL)
  req = Net::HTTP::Post.new(uri)
  base_headers(cookie).each { |k, v| req[k] = v }
  req["Content-Type"] = "application/x-www-form-urlencoded"
  req["Origin"] = "https://24h.webcup.fr"
  req["Referer"] = DASHBOARD_URL
  req.body = URI.encode_www_form(
    "action" => "webcup_v2_save_feature_declaration",
    "feature_intent" => "save",
    "request_code" => decl["id"],
    "webcup_v2_feature_nonce" => nonce,
    "_wp_http_referer" => REFERER,
    "implemented" => decl["implemented"].to_s,
    "test_url" => decl["test_url"].to_s,
    "jury_instructions" => decl["jury_instructions"].to_s
  )

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(req) }
end

nonce = fetch_nonce(cookie)
puts "Nonce récupéré : #{nonce}"

ok = 0
failed = []
declarations.each do |decl|
  if submit
    begin
      res = post_declaration(cookie, nonce, decl)
      if res.is_a?(Net::HTTPSuccess) || res.is_a?(Net::HTTPRedirection)
        ok += 1
        puts "  ✓ #{decl['id']}"
      else
        failed << decl["id"]
        puts "  ! #{decl['id']} : HTTP #{res.code}"
      end
    rescue StandardError => e
      failed << decl["id"]
      puts "  ! #{decl['id']} : #{e.class}: #{e.message}"
    end
  else
    puts "  · #{decl['id']} → #{decl['test_url']}"
  end
end

if submit
  puts "\nTerminé : #{ok} envoyée(s), #{failed.size} échec(s)."
  puts "Échecs : #{failed.join(', ')}" unless failed.empty?
else
  puts "\nDry-run terminé. Relance avec --submit pour envoyer."
end
