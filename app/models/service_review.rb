# frozen_string_literal: true

# A citizen's comment after using a service (F76).
class ServiceReview < ApplicationRecord
  has_paper_trail ignore: %i[updated_at]

  belongs_to :service
  belongs_to :user

  enum :status, { published: "published", hidden: "hidden" }, default: :published, validate: true

  validates :rating, numericality: { in: 1..5 }, allow_nil: true
  validates :comment, presence: true, length: { maximum: 2000 }
  validates :user_id, uniqueness: { scope: :service_id }
  validates :reference, presence: true, uniqueness: true

  before_validation :ensure_reference, on: :create

  scope :recent_first, -> { order(created_at: :desc) }
  scope :visible, -> { where(status: "published") }

  def to_param
    reference
  end

  private

  def ensure_reference
    return if reference.present?

    self.reference = loop do
      candidate = "AVIS-#{Time.current.year}-#{SecureRandom.alphanumeric(5).upcase}"
      break candidate unless ServiceReview.exists?(reference: candidate)
    end
  end
end
