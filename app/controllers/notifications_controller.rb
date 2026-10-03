# frozen_string_literal: true

class NotificationsController < ApplicationController
  include CitizenSpace

  def index
    @notifications = current_user.notifications.recent_first.limit(100)
    @unread_count = current_user.notifications.unread.count
  end

  def update
    @notification = current_user.notifications.find(params[:id])
    @notification.mark_as_read!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          ActionView::RecordIdentifier.dom_id(@notification),
          partial: "notifications/notification",
          locals: { notification: @notification }
        )
      end
      format.html { redirect_to notifications_path }
    end
  end
end
