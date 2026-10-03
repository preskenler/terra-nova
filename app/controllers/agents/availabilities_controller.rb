# frozen_string_literal: true

module Agents
  # Manage weekly availability slots used to compute bookable appointments.
  class AvailabilitiesController < BaseController
    def index
      authorize AgentAvailability
      load_data
    end

    def create
      @availability = current_agent.agent_availabilities.new(availability_params)
      authorize @availability

      if @availability.save
        redirect_to agents_availabilities_path, notice: t("agents.availabilities.created")
      else
        load_data
        render :index, status: :unprocessable_content
      end
    end

    def destroy
      @availability = current_agent.agent_availabilities.find(params[:id])
      authorize @availability
      @availability.destroy
      redirect_to agents_availabilities_path, notice: t("agents.availabilities.destroyed")
    end

    private

    def load_data
      @availabilities = current_agent.agent_availabilities.ordered
      @time_offs = current_agent.agent_time_offs.order(:starts_at)
      @availability ||= current_agent.agent_availabilities.new(slot_minutes: 30, active: true)
      @time_off ||= current_agent.agent_time_offs.new
    end

    def availability_params
      params.require(:agent_availability).permit(:wday, :start_time, :end_time, :slot_minutes, :active)
    end
  end
end
