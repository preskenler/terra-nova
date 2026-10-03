# frozen_string_literal: true

# Urgent municipal alert (flood, heatwave, security...) possibly geo/segment
# targeted (F29/F31).
class Alert < ApplicationRecord
  include Translatable
  has_paper_trail ignore: %i[updated_at]

  translates :title, :body

  KINDS = {
    flood: "flood",
    heatwave: "heatwave",
    security: "security",
    other: "other"
  }.freeze

  SEVERITIES = { info: "info", alert: "alert", critical: "critical" }.freeze
  SEGMENTS = { everyone: "all", vulnerable: "vulnerable", residents: "residents" }.freeze

  enum :kind, KINDS, default: :other, validate: true
  enum :severity, SEVERITIES, default: :alert, validate: true
  enum :target_segment, SEGMENTS, default: :all, validate: true

  validates :title, presence: true
  validates :body, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :active_now, lambda {
    where(active: true)
      .where("starts_at IS NULL OR starts_at <= ?", Time.current)
      .where("ends_at IS NULL OR ends_at >= ?", Time.current)
  }

  def critical?
    severity == "critical"
  end
end
