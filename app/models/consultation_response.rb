# frozen_string_literal: true

# A citizen's recorded answer to a consultation, with a traceable reference
# (F65/F66).
class ConsultationResponse < ApplicationRecord
  belongs_to :consultation
  belongs_to :user

  validates :choice, presence: true
  validates :reference, presence: true, uniqueness: true
  validates :user_id, uniqueness: { scope: :consultation_id }

  before_validation :ensure_reference, on: :create

  scope :recent_first, -> { order(created_at: :desc) }

  def to_param
    reference
  end

  private

  def ensure_reference
    return if reference.present?

    self.reference = loop do
      candidate = "PART-#{Time.current.year}-#{SecureRandom.alphanumeric(5).upcase}"
      break candidate unless ConsultationResponse.exists?(reference: candidate)
    end
  end
end
