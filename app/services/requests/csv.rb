# frozen_string_literal: true

require "csv"

module Requests
  # Builds an exportable recap of a citizen's requests (F56).
  class Csv
    HEADERS = [
      "Reference", "Submitted at", "Subject", "Status",
      "Service", "Location", "Steps", "Supporters", "Last update"
    ].freeze

    def self.call(requests)
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        requests.each do |request|
          csv << [
            request.reference,
            I18n.l(request.created_at, format: :short),
            request.subject,
            I18n.t("requests.status.#{request.status}"),
            request.service&.name,
            request.location_text,
            request.request_events.size,
            request.request_supports.size,
            I18n.l(request.updated_at, format: :short)
          ]
        end
      end
    end
  end
end
