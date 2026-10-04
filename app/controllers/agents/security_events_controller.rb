# frozen_string_literal: true

module Agents
  # Read-only monitoring of security events (F69). Administrators only (F70).
  class SecurityEventsController < BaseController
    def index
      authorize :security_event, :index?

      scope = SecurityEvent.recent_first
      scope = scope.where(event: params[:event]) if params[:event].present?
      @events = scope.limit(200).to_a
      @event_types = SecurityEvent.distinct.order(:event).pluck(:event)

      # Recent activity summary that flags unusual volumes (F85).
      @summary = Security::EventsSummary.new(period: 1.hour).call
    end
  end
end
