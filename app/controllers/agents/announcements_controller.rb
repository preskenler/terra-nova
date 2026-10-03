# frozen_string_literal: true

module Agents
  # Administer municipal announcements (D18/F30).
  class AnnouncementsController < BaseController
    before_action :set_announcement, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize Announcement
      @announcements = Announcement.recent_first
    end

    def show
      authorize @announcement
    end

    def new
      @announcement = Announcement.new(published_at: Time.current, active: true)
      authorize @announcement
    end

    def create
      @announcement = Announcement.new(announcement_params)
      @announcement.published_at ||= Time.current
      authorize @announcement

      if @announcement.save
        notify_citizens(@announcement)
        redirect_to agents_announcement_path(@announcement), notice: t("agents.announcements.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @announcement
    end

    def update
      authorize @announcement

      if @announcement.update(announcement_params)
        redirect_to agents_announcement_path(@announcement), notice: t("agents.announcements.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @announcement
      @announcement.destroy
      redirect_to agents_announcements_path, notice: t("agents.announcements.destroyed")
    end

    private

    def set_announcement
      @announcement = Announcement.find(params[:id])
    end

    def announcement_params
      params.require(:announcement).permit(
        :severity, :target_audience, :published_at, :starts_at, :ends_at, :active,
        :title_fr, :title_en, :body_fr, :body_en
      )
    end

    def notify_citizens(record)
      return unless record.audience_includes_citizens? && record.active?

      User.find_each do |user|
        user.notifications.create!(
          kind: "announcement", notifiable: record, title: record.title, body: record.body
        )
      end
    end
  end
end
