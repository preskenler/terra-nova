# frozen_string_literal: true

module Agents
  class DashboardController < BaseController
    def index
      authorize :dashboard, :index?

      @demand_count = Demand.count
      @unseen_demand_count = Demand.new_arrivals.count
      @pending_demand_count = Demand.pending_triage.count
      @latest_sync = DemandSync.latest
      @recent_demands = Demand.recently_seen.limit(5)
    end
  end
end
