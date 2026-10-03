# frozen_string_literal: true

# Suggests services and a starting point based on a citizen's situation, without
# repeating the registration onboarding (F72).
class CitizenGuidance
  SITUATIONS = {
    moving_in: { services: %w[etat-civil collecte-dechets transports], request: nil },
    waste: { services: %w[collecte-dechets], request: :waste },
    streetlight: { services: %w[eclairage-public], request: :streetlight },
    health: { services: %w[sante urgences], request: nil },
    transport: { services: %w[transports], request: nil },
    permits: { services: %w[urbanisme], request: nil },
    water: { services: %w[eau-assainissement], request: :water }
  }.freeze

  def self.call(situation)
    key = situation.to_s.to_sym
    return nil unless SITUATIONS.key?(key)

    new(key).call
  end

  def initialize(key)
    @key = key
  end

  def call
    config = SITUATIONS.fetch(@key)
    {
      situation: @key,
      services: Service.publicly_visible.where(slug: config[:services]).ordered.to_a,
      request_key: config[:request]
    }
  end
end
