# frozen_string_literal: true

# Recurring weekly availability for an agent (used to compute bookable slots).
class AgentAvailability < ApplicationRecord
  belongs_to :agent

  validates :wday, inclusion: { in: 0..6 }
  validates :start_time, :end_time, presence: true
  validates :slot_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 480 }

  validate :end_after_start

  scope :active, -> { where(active: true) }
  scope :for_day, ->(wday) { active.where(wday: wday) }
  scope :ordered, -> { order(:wday, :start_time) }

  private

  def end_after_start
    return if start_time.blank? || end_time.blank?

    errors.add(:end_time, :invalid) if end_time <= start_time
  end
end
