# frozen_string_literal: true

class AnnouncementsController < ApplicationController
  def index
    @announcements = Announcement.published.for_audience("citizens").recent_first
  end

  def show
    @announcement = Announcement.published.for_audience("citizens").find(params[:id])
  end
end
