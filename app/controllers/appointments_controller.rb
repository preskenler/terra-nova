# frozen_string_literal: true

# Citizen appointment booking (F39/F40).
class AppointmentsController < ApplicationController
  include CitizenSpace

  def index
    @appointments = current_user.appointments.includes(:agent, :service).recent_first
  end

  def show
    @appointment = current_user.appointments.find(params[:id])
    authorize @appointment
  end

  def new
    load_form_data
    @slots = @agent ? Appointments::AvailableSlots.new(agent: @agent, date: @date).call : []
  end

  def create
    @appointment = current_user.appointments.new(appointment_params)
    @appointment.status = :confirmed
    authorize @appointment

    if @appointment.save
      after_booking(@appointment)
      redirect_to appointment_path(@appointment), notice: t("appointments.created")
    else
      load_form_data
      @slots = @agent ? Appointments::AvailableSlots.new(agent: @agent, date: @date).call : []
      render :new, status: :unprocessable_content
    end
  end

  def cancel
    @appointment = current_user.appointments.find(params[:id])
    authorize @appointment, :cancel?

    @appointment.update(status: "cancelled", cancellation_reason: params[:reason])
    redirect_to appointment_path(@appointment), notice: t("appointments.cancelled")
  end

  private

  def load_form_data
    @agents = Agent.order(:email)
    @services = Service.publicly_visible.ordered
    @agent = Agent.find_by(id: params[:agent_id]) ||
             @appointment&.agent ||
             @agents.find { |candidate| candidate.agent_availabilities.active.exists? } ||
             @agents.first
    @date = parse_date(params[:date]) || next_available_date(@agent)
  end

  def after_booking(appointment)
    AppointmentMailer.confirmation(appointment).deliver_later
    current_user.notifications.create!(
      kind: "appointment",
      notifiable: appointment,
      title: t("notifications.appointment.title"),
      body: t("notifications.appointment.body", date: l(appointment.starts_at, format: :short))
    )
  end

  def appointment_params
    params.require(:appointment).permit(:agent_id, :service_id, :starts_at, :notes, :duration_minutes)
  end

  def parse_date(value)
    Date.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def next_available_date(agent)
    return Date.current if agent.blank?

    (0..14).each do |offset|
      date = Date.current + offset.days
      return date if agent.agent_availabilities.active.exists?(wday: date.wday)
    end
    Date.current
  end
end
