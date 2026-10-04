# frozen_string_literal: true

module Agents
  # Administrator-only data backup of citizen requests (F87). Produces a clear,
  # verifiable CSV rather than a raw dump, so the responsible teams can confirm
  # important data can be saved and reused.
  class ExportsController < BaseController
    def requests
      authorize :export, :requests?

      exporter = Exports::Requests.new(
        scope: Request.includes(:user, :service).recent_first,
        actor: current_agent
      )

      send_data exporter.call,
                filename: exporter.filename,
                type: "text/csv; charset=utf-8"
    end
  end
end
