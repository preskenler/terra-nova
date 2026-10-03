# frozen_string_literal: true

class TransportDisruption < ApplicationRecord
  include Translatable
  translates :message

  belongs_to :transport_line

  SEVERITIES = %w[info warning critical].freeze
  validates :severity, inclusion: { in: SEVERITIES }

  scope :active_now, -> { where(active: true).where("ends_at IS NULL OR ends_at >= ?", Time.current) }
end
