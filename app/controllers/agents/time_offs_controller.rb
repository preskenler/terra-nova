# frozen_string_literal: true

module Agents
  # Manage blocked periods (holidays, training...) during which an agent cannot
  # be booked.
  class TimeOffsController < BaseController
    def create
      @time_off = current_agent.agent_time_offs.new(time_off_params)
      authorize @time_off

      if @time_off.save
        redirect_to agents_availabilities_path, notice: t("agents.time_offs.created")
      else
        redirect_to agents_availabilities_path,
                    alert: @time_off.errors.full_messages.to_sentence
      end
    end

    def destroy
      @time_off = current_agent.agent_time_offs.find(params[:id])
      authorize @time_off
      @time_off.destroy
      redirect_to agents_availabilities_path, notice: t("agents.time_offs.destroyed")
    end

    private

    def time_off_params
      params.require(:agent_time_off).permit(:starts_at, :ends_at, :reason)
    end
  end
end
