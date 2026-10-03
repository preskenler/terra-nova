# frozen_string_literal: true

# Citizen personal space (D03).
class DashboardController < ApplicationController
  include CitizenSpace

  def show
    @profile = current_user.profile || current_user.create_profile
    @request_count = current_user.requests.count
    @open_request_count = current_user.requests.open_requests.count
    @appointment_count = current_user.appointments.upcoming.active.count
    @unread_notification_count = current_user.notifications.unread.count
    @recent_requests = current_user.requests.recent_first.limit(3)
  end
end
