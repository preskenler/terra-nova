# frozen_string_literal: true

# A citizen's signalement/demande (F25/F26/D11/D16). Distinct from +Demand+,
# which is the external Webcup API feed.
class Request < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  STATUSES = {
    submitted: "submitted",
    acknowledged: "acknowledged",
    in_progress: "in_progress",
    resolved: "resolved",
    closed: "closed",
    rejected: "rejected"
  }.freeze

  # Statuses considered "open" (still needing action).
  OPEN_STATUSES = %w[submitted acknowledged in_progress].freeze

  belongs_to :user
  belongs_to :service, optional: true

  # Duplicate detection (F75): a request can be linked to the one it duplicates.
  belongs_to :duplicate_of, class_name: "Request", optional: true
  has_many :duplicates, class_name: "Request", foreign_key: :duplicate_of_id, dependent: :nullify

  has_many :request_events, -> { order(created_at: :asc, id: :asc) }, dependent: :destroy
  has_many :request_supports, dependent: :destroy
  has_many :supporters, through: :request_supports, source: :user

  enum :status, STATUSES, default: :submitted, validate: true

  validates :subject, presence: true, length: { maximum: 150 }
  validates :description, presence: true, length: { maximum: 5000 }
  validates :reference, presence: true, uniqueness: true

  before_validation :ensure_reference, on: :create

  scope :recent_first, -> { order(created_at: :desc) }
  scope :open_requests, -> { where(status: OPEN_STATUSES) }

  # URL-friendly and stable public identifier.
  def to_param
    reference
  end

  def supported_by?(user)
    return false if user.nil?

    request_supports.exists?(user_id: user.id)
  end

  def support_count
    request_supports.count
  end

  # Latest citizen-visible event.
  def latest_public_event
    request_events.where(visible_to_citizen: true).last
  end

  private

  def ensure_reference
    return if reference.present?

    self.reference = loop do
      candidate = "NOVA-#{Time.current.year}-#{SecureRandom.alphanumeric(5).upcase}"
      break candidate unless Request.exists?(reference: candidate)
    end
  end
end
