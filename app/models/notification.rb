# frozen_string_literal: true

# In-app notification for a citizen (F30/F49).
class Notification < ApplicationRecord
  KINDS = {
    general: "general",
    status_change: "status_change",
    reply: "reply",
    appointment: "appointment",
    announcement: "announcement",
    alert: "alert"
  }.freeze

  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  enum :kind, KINDS, default: :general, validate: true

  validates :title, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update(read_at: Time.current) unless read?
  end
end
