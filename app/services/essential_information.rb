# frozen_string_literal: true

# A minimal, DB-light snapshot of the information a citizen may need during an
# incident (F93/F94): emergency services and contacts, key procedures and the
# current alerts. It is cached and defensive, so the essentials remain
# understandable and recoverable even when heavier parts of the platform are
# degraded.
class EssentialInformation
  CACHE_KEY = "essential_information"
  CACHE_TTL = 5.minutes

  def self.call
    new.call
  end

  def call
    Rails.cache.fetch(CACHE_KEY, expires_in: CACHE_TTL) { build }
  rescue StandardError => e
    Rails.logger.warn("EssentialInformation degraded: #{e.class}: #{e.message}")
    fallback
  end

  private

  def build
    {
      emergency_services: emergency_services,
      procedures: procedures,
      alerts: alerts,
      degraded: false
    }
  end

  # Static emergency contacts, always available (never dependent on the DB).
  def emergency_services
    [
      { name: I18n.t("essentials.emergency.samu"), phone: "15" },
      { name: I18n.t("essentials.emergency.police"), phone: "17" },
      { name: I18n.t("essentials.emergency.fire"), phone: "18" },
      { name: I18n.t("essentials.emergency.european"), phone: "112" }
    ]
  end

  def procedures
    Service.publicly_visible.priorities.ordered.limit(4).map do |service|
      { name: service.name, phone: service.contact_phone, slug: service.slug }
    end
  end

  def alerts
    Alert.active_now.recent_first.limit(3).map do |alert|
      { title: alert.title, body: alert.body, severity: alert.severity }
    end
  end

  # When the database itself is unreachable, keep the static essentials.
  def fallback
    {
      emergency_services: emergency_services,
      procedures: [],
      alerts: [],
      degraded: true
    }
  end
end
