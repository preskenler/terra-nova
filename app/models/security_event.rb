# frozen_string_literal: true

# Security-relevant events, surfaced to administrators for monitoring (F69).
class SecurityEvent < ApplicationRecord
  belongs_to :actor, polymorphic: true, optional: true

  validates :event, presence: true

  scope :recent_first, -> { order(created_at: :desc) }

  # Best-effort logging: never let monitoring break a request.
  def self.log(event, request: nil, actor: nil, metadata: {})
    create!(
      event: event,
      actor: actor,
      ip: request&.remote_ip,
      user_agent: request&.user_agent.to_s.first(255),
      metadata: metadata
    )
  rescue StandardError => e
    Rails.logger.warn("SecurityEvent logging failed: #{e.class}: #{e.message}")
  end
end
