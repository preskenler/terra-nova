# frozen_string_literal: true

# Public orientation assistant: describe a need in free text and be routed to
# the right municipal service or procedure (F91/F92). Purely heuristic; no
# external AI dependency.
class AssistantController < ApplicationController
  def show
    @query = params[:q]
    @result = CitizenAssistant.call(@query) if @query.present?
    @examples = CitizenAssistant::CATEGORY_KEYWORDS.values.flatten.first(6)
  end
end
