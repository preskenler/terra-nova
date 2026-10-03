# frozen_string_literal: true

# A citizen co-signing/supporting another citizen's request (F52).
class RequestSupport < ApplicationRecord
  belongs_to :request
  belongs_to :user

  validates :user_id, uniqueness: { scope: :request_id }
end
