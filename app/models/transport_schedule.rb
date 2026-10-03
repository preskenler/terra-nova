# frozen_string_literal: true

class TransportSchedule < ApplicationRecord
  belongs_to :transport_line

  validates :wday, inclusion: { in: 0..6 }
  validates :frequency_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
end
