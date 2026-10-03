# One row per poll of the external Webcup API, capturing the +session+ block
# and the outcome of the call. Keeps last-good state available for the agent
# console when the API is unreachable.
class DemandSync < ApplicationRecord
  scope :recent_first, -> { order(fetched_at: :desc, id: :desc) }
  scope :successful, -> { where(success: true) }

  def self.latest
    recent_first.first
  end

  def self.latest_successful
    successful.recent_first.first
  end
end
