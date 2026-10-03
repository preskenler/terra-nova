# frozen_string_literal: true

module Agents
  # Administer urgent alerts (F29/F31).
  class AlertsController < BaseController
    before_action :set_alert, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize Alert
      @alerts = Alert.recent_first
    end

    def show
      authorize @alert
    end

    def new
      @alert = Alert.new(active: true, starts_at: Time.current, severity: "alert")
      authorize @alert
    end

    def create
      @alert = Alert.new(alert_params)
      authorize @alert

      if @alert.save
        notify_citizens(@alert)
        redirect_to agents_alert_path(@alert), notice: t("agents.alerts.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @alert
    end

    def update
      authorize @alert

      if @alert.update(alert_params)
        redirect_to agents_alert_path(@alert), notice: t("agents.alerts.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @alert
      @alert.destroy
      redirect_to agents_alerts_path, notice: t("agents.alerts.destroyed")
    end

    private

    def set_alert
      @alert = Alert.find(params[:id])
    end

    def alert_params
      params.require(:alert).permit(
        :kind, :severity, :target_segment, :locality, :latitude, :longitude, :radius_km,
        :starts_at, :ends_at, :active,
        :title_fr, :title_en, :body_fr, :body_en
      )
    end

    def notify_citizens(record)
      return unless record.active?

      User.find_each do |user|
        user.notifications.create!(
          kind: "alert", notifiable: record, title: record.title, body: record.body
        )
      end
    end
  end
end
