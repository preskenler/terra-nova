# frozen_string_literal: true

# Citizen personal space (D03).
class DashboardController < ApplicationController
  include CitizenSpace

  def show
    @profile = current_user.profile || current_user.create_profile
    @request_count = 0
    @open_request_count = 0
    @appointment_count = 0
    @latest_announcement = nil
  end
end
