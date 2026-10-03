# frozen_string_literal: true

# A citizen supporting another citizen's idea (F68).
class IdeaSupport < ApplicationRecord
  belongs_to :idea
  belongs_to :user

  validates :user_id, uniqueness: { scope: :idea_id }
end
