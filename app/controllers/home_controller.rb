# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @priority_services = Service.publicly_visible.priorities.ordered.limit(6)
    @emergency_services = Service.publicly_visible.emergencies.ordered.limit(3)
    @announcements = Announcement.published.for_audience("citizens").recent_first.limit(3)
    @alerts = Alert.active_now.recent_first.limit(3)
  end
end
