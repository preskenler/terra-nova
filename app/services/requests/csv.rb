# frozen_string_literal: true

require "csv"

module Requests
  # Builds an exportable recap of requests (F56/F88/F87).
  #
  # +detailed:+ adds the priority and the requesting citizen, so the agent
  # workspace can export the exact filtered selection (F88) and administrators
  # can produce a reusable backup (F87).
  class Csv
    CITIZEN_HEADERS = [
      "Reference", "Submitted at", "Subject", "Status",
      "Service", "Location", "Steps", "Supporters", "Last update"
    ].freeze

    AGENT_HEADERS = [
      "Reference", "Submitted at", "Subject", "Status", "Priority",
      "Citizen", "Service", "Location", "Steps", "Supporters", "Last update"
    ].freeze

    def self.call(requests, detailed: false)
      CSV.generate(headers: true) do |csv|
        csv << (detailed ? AGENT_HEADERS : CITIZEN_HEADERS)
        requests.each do |request|
          row = [
            request.reference,
            I18n.l(request.created_at, format: :short),
            request.subject,
            I18n.t("requests.status.#{request.status}")
          ]
          row += [ I18n.t("requests.priority.#{request.priority}"), request.user&.email ] if detailed
          row += [
            request.service&.name,
            request.location_text,
            request.request_events.size,
            request.request_supports.size,
            I18n.l(request.updated_at, format: :short)
          ]
          csv << row
        end
      end
    end
  end
end
