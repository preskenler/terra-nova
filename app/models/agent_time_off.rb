# frozen_string_literal: true

# Blocked periods during which an agent cannot be booked.
class AgentTimeOff < ApplicationRecord
  belongs_to :agent

  validates :starts_at, :ends_at, presence: true

  validate :ends_after_start

  scope :covering, ->(range) { where("starts_at < ? AND ends_at > ?", range.max, range.min) }

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, :invalid) if ends_at <= starts_at
  end
end
