# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Short-lived caching keeps the homepage fast under load (F77/F78).
    @priority_services = Rails.cache.fetch("home:priority_services", expires_in: 5.minutes) do
      Service.publicly_visible.priorities.ordered.limit(6).to_a
    end
    @emergency_services = Rails.cache.fetch("home:emergency_services", expires_in: 5.minutes) do
      Service.publicly_visible.emergencies.ordered.limit(3).to_a
    end
    @announcements = Rails.cache.fetch("home:announcements", expires_in: 2.minutes) do
      Announcement.published.for_audience("citizens").recent_first.limit(3).to_a
    end
    @alerts = Rails.cache.fetch("home:alerts", expires_in: 1.minute) do
      Alert.active_now.recent_first.limit(3).to_a
    end
  end
end
