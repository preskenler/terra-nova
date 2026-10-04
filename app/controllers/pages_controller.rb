# frozen_string_literal: true

# Static trust, accessibility and environmental pages.
class PagesController < ApplicationController
  def transparency
  end

  def accessibility
  end

  # Environmental diagnosis and weight report (F57/F58).
  def eco
    @report = Eco::Report.call
  end

  # Essential information that stays available during an incident (F93/F94).
  def essentials
    @information = EssentialInformation.call
  end

  # Lightweight public system status page (F77/F78).
  def status
    @database_ok = begin
      ActiveRecord::Base.connection.active?
    rescue StandardError
      false
    end
    @cache_ok = begin
      Rails.cache.write("status:check", Time.current)
      true
    rescue StandardError
      false
    end
    @last_sync = DemandSync.latest
    @counts = { services: Service.count, requests: Request.count, demands: Demand.count }
  end
end
