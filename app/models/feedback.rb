# frozen_string_literal: true

# Message sent to the municipal services by a citizen or a visitor (D04).
# Also used to collect data-usage concerns (F51).
class Feedback < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  KINDS = {
    question: "question",
    complaint: "complaint",
    suggestion: "suggestion",
    data_concern: "data_concern"
  }.freeze

  STATUSES = {
    received: "new",
    in_review: "in_review",
    resolved: "resolved"
  }.freeze

  belongs_to :user, optional: true

  enum :kind, KINDS, default: :question, validate: true
  enum :status, STATUSES, default: :received, validate: true

  validates :subject, presence: true, length: { maximum: 150 }
  validates :message, presence: true, length: { maximum: 5000 }
  validates :reference, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :contactable

  before_validation :ensure_reference, on: :create

  scope :recent_first, -> { order(created_at: :desc) }

  def to_param
    reference
  end

  # An anonymous message must provide an email so we can answer.
  def contactable
    return if user.present? || email.present?

    errors.add(:email, :blank)
  end

  private

  def ensure_reference
    return if reference.present?

    self.reference = loop do
      candidate = "MSG-#{Time.current.year}-#{SecureRandom.alphanumeric(5).upcase}"
      break candidate unless Feedback.exists?(reference: candidate)
    end
  end
end
