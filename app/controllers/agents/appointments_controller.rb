# frozen_string_literal: true

module Agents
  # Agent appointment schedule management (F39/F40).
  class AppointmentsController < BaseController
    def index
      authorize Appointment

      @appointments = current_agent.appointments.includes(:user, :service).recent_first
      @upcoming = @appointments.select { |appointment| appointment.starts_at >= Time.current && %w[requested confirmed].include?(appointment.status) }
    end

    def show
      @appointment = current_agent.appointments.find(params[:id])
      authorize @appointment
    end

    def edit
      @appointment = current_agent.appointments.find(params[:id])
      authorize @appointment
    end

    def update
      @appointment = current_agent.appointments.find(params[:id])
      authorize @appointment

      if @appointment.update(appointment_params)
        redirect_to agents_appointment_path(@appointment), notice: t("agents.appointments.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def cancel
      @appointment = current_agent.appointments.find(params[:id])
      authorize @appointment, :cancel?

      @appointment.update(status: "cancelled", cancellation_reason: params[:reason])
      notify_cancellation(@appointment)
      redirect_to agents_appointment_path(@appointment), notice: t("agents.appointments.cancelled")
    end

    private

    def appointment_params
      params.require(:appointment).permit(:starts_at, :service_id, :notes, :status, :duration_minutes)
    end

    def notify_cancellation(appointment)
      appointment.user.notifications.create!(
        kind: "appointment",
        notifiable: appointment,
        title: t("notifications.appointment_cancelled.title"),
        body: t("notifications.appointment_cancelled.body", date: l(appointment.starts_at, format: :short))
      )
    end
  end
end
