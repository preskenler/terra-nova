# frozen_string_literal: true

# A booked appointment between a citizen and an agent (F39/F40).
class Appointment < ApplicationRecord
  has_paper_trail ignore: %i[updated_at reminder_sent_at]

  STATUSES = {
    requested: "requested",
    confirmed: "confirmed",
    cancelled: "cancelled",
    completed: "completed",
    no_show: "no_show"
  }.freeze

  belongs_to :user
  belongs_to :agent
  belongs_to :service, optional: true

  enum :status, STATUSES, default: :confirmed, validate: true

  validates :starts_at, presence: true
  validates :duration_minutes, numericality: { greater_than: 0, less_than_or_equal_to: 480 }

  validate :ends_after_start
  validate :no_overlap, on: :create

  before_validation :assign_ends_at

  scope :recent_first, -> { order(starts_at: :desc) }
  scope :upcoming, -> { where("starts_at >= ?", Time.current).order(:starts_at) }
  scope :active, -> { where(status: %w[requested confirmed]) }
  scope :pending_reminder, -> { active.where(reminder_sent_at: nil) }

  def start_passed?
    starts_at.present? && starts_at < Time.current
  end

  private

  def assign_ends_at
    self.duration_minutes ||= 30
    self.ends_at = starts_at + duration_minutes.minutes if starts_at.present?
  end

  def ends_after_start
    return if starts_at.blank? || ends_at.blank?

    errors.add(:ends_at, :invalid) if ends_at <= starts_at
  end

  def no_overlap
    return if agent_id.blank? || starts_at.blank? || ends_at.blank?

    overlapping = Appointment
                    .where(agent_id: agent_id, status: %w[requested confirmed])
                    .where("starts_at < ? AND ends_at > ?", ends_at, starts_at)
    overlapping = overlapping.where.not(id: id) if persisted?

    errors.add(:starts_at, :taken) if overlapping.exists?
  end
end
