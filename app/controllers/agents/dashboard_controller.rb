# frozen_string_literal: true

module Agents
  class DashboardController < BaseController
    def index
      authorize :dashboard, :index?

      # External API demands (D19)
      @demand_count = Demand.count
      @unseen_demand_count = Demand.new_arrivals.count
      @pending_demand_count = Demand.pending_triage.count
      @latest_sync = DemandSync.latest
      @recent_demands = Demand.recently_seen.limit(5)

      # Platform activity (F50)
      @user_count = User.count
      @request_count = Request.count
      @pending_request_count = Request.open_requests.count
      @upcoming_appointment_count = Appointment.upcoming.active.count
      @recent_requests = Request.includes(:user).recent_first.limit(5)
    end
  end
end
