# frozen_string_literal: true

class AlertsController < ApplicationController
  def index
    @alerts = Alert.active_now.recent_first
  end
end
