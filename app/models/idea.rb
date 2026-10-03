# frozen_string_literal: true

# An idea proposed by a citizen to improve the city (F68).
class Idea < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  belongs_to :user
  has_many :idea_supports, dependent: :destroy
  has_many :supporters, through: :idea_supports, source: :user

  CATEGORIES = Project::CATEGORIES
  STATUSES = {
    submitted: "submitted",
    under_review: "under_review",
    accepted: "accepted",
    declined: "declined"
  }.freeze

  enum :status, STATUSES, default: :submitted, validate: true

  validates :title, presence: true, length: { maximum: 150 }
  validates :description, presence: true, length: { maximum: 5000 }
  validates :reference, presence: true, uniqueness: true

  before_validation :ensure_reference, on: :create

  scope :recent_first, -> { order(created_at: :desc) }

  def to_param
    reference
  end

  def supported_by?(user)
    user.present? && idea_supports.exists?(user_id: user.id)
  end

  def support_count
    idea_supports.count
  end

  private

  def ensure_reference
    return if reference.present?

    self.reference = loop do
      candidate = "IDEA-#{Time.current.year}-#{SecureRandom.alphanumeric(5).upcase}"
      break candidate unless Idea.exists?(reference: candidate)
    end
  end
end
