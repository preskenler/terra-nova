# frozen_string_literal: true

# A traceable step in a request's lifecycle (D11). Authorship is polymorphic so
# both citizens and agents can create events.
class RequestEvent < ApplicationRecord
  belongs_to :request
  belongs_to :created_by, polymorphic: true, optional: true

  validates :to_status, presence: true, inclusion: { in: Request::STATUSES.values }

  scope :chronological, -> { order(created_at: :asc, id: :asc) }
  scope :visible_to_citizens, -> { where(visible_to_citizen: true) }

  def status_changed?
    from_status.present? && from_status != to_status
  end
end
