# frozen_string_literal: true

# Municipal announcement shown to citizens and/or agents (D06/D18/F30).
class Announcement < ApplicationRecord
  include Translatable
  has_paper_trail ignore: %i[updated_at]

  translates :title, :body

  SEVERITIES = { info: "info", alert: "alert", critical: "critical" }.freeze
  AUDIENCES  = { everyone: "all", citizens: "citizens", agents: "agents" }.freeze

  enum :severity, SEVERITIES, default: :info, validate: true
  enum :target_audience, AUDIENCES, default: :all, validate: true

  validates :title, presence: true
  validates :body, presence: true

  scope :recent_first, -> { order(published_at: :desc, created_at: :desc) }
  scope :published, lambda {
    where(active: true)
      .where("starts_at IS NULL OR starts_at <= ?", Time.current)
      .where("ends_at IS NULL OR ends_at >= ?", Time.current)
  }
  scope :for_audience, ->(audience) { where(target_audience: [ "all", audience ]) }

  def published?
    active? && (starts_at.nil? || starts_at <= Time.current) && (ends_at.nil? || ends_at >= Time.current)
  end

  def audience_includes_citizens?
    %w[everyone citizens].include?(target_audience)
  end
end
