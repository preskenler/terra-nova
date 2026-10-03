# frozen_string_literal: true

# An agent's reply on a citizen request (F84). Public replies are visible to the
# citizen and notify them; internal replies are kept for the agent workspace.
class RequestReply < ApplicationRecord
  belongs_to :request
  belongs_to :created_by, polymorphic: true, optional: true

  validates :body, presence: true, length: { maximum: 5000 }

  scope :chronological, -> { order(created_at: :asc, id: :asc) }
  scope :public_replies, -> { where(internal: false) }

  def by_agent?
    created_by_type == "Agent"
  end

  def internal?
    internal
  end
end
