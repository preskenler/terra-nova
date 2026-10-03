# frozen_string_literal: true

# A consultation asking citizens for their opinion (F65/F66).
class Consultation < ApplicationRecord
  include Translatable
  has_paper_trail ignore: %i[updated_at]

  translates :title, :description

  belongs_to :project, optional: true
  has_many :consultation_responses, dependent: :destroy

  KINDS = { opinion: "opinion", poll: "poll", decision: "decision" }.freeze
  STATUSES = { draft: "draft", open: "open", closed: "closed" }.freeze

  enum :kind, KINDS, default: :opinion, validate: true
  enum :status, STATUSES, default: :draft, validate: true

  validates :title, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :published, -> { where(status: %w[open closed]) }
  scope :open_now, lambda {
    where(status: "open")
      .where("opens_at IS NULL OR opens_at <= ?", Time.current)
      .where("closes_at IS NULL OR closes_at >= ?", Time.current)
  }

  def response_from(user)
    return nil if user.nil?

    consultation_responses.find_by(user_id: user.id)
  end

  def responded_by?(user)
    response_from(user).present?
  end

  def open_for_response?
    status == "open" &&
      (opens_at.nil? || opens_at <= Time.current) &&
      (closes_at.nil? || closes_at >= Time.current)
  end
end
