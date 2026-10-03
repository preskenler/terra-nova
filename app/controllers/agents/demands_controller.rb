# frozen_string_literal: true

module Agents
  # Live console for the demands broadcast by the external Webcup API (D19).
  # Demands are upserted by background/manual sync; agents triage them here.
  class DemandsController < BaseController
    PER_PAGE = 25

    def index
      authorize Demand

      # First visit (or after a reset) fetches synchronously so the console is
      # never empty; afterwards the recurring job / poller keeps it fresh.
      sync_if_empty

      load_sync
      load_demands
    end

    def show
      @demand = Demand.find(params[:id])
      authorize @demand
      @sync = DemandSync.latest
    end

    def update
      @demand = Demand.find(params[:id])
      authorize @demand

      if @demand.update(demand_params)
        redirect_to agents_demand_path(@demand), notice: t("demands.updated")
      else
        @sync = DemandSync.latest
        render :show, status: :unprocessable_content
      end
    end

    # POST: trigger a poll and refresh the console without a full page reload.
    def refresh
      authorize Demand, :refresh?

      @result = Demands::Sync.call
      load_sync
      load_demands

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to agents_demands_path, notice: t("demands.refreshed") }
      end
    end

    private

    def sync_if_empty
      return unless TerraNova::Webcup.configured?
      return if DemandSync.latest.present?

      Demands::Sync.call
    end

    def load_sync
      @sync = DemandSync.latest
      @latest_successful_sync = DemandSync.latest_successful
      @api_configured = TerraNova::Webcup.configured?
      @unseen_count = Demand.new_arrivals.count
      @waves = Demand.where.not(wave_number: nil).distinct.order(:wave_number).pluck(:wave_number)
    end

    def load_demands
      scope = Demand.recently_seen
      scope = scope.where(triage_status: params[:status]) if params[:status].present?
      scope = scope.by_wave(params[:wave]) if params[:wave].present?
      scope = scope.by_difficulty(params[:difficulty]) if params[:difficulty].present?

      if params[:q].present?
        query = "%#{params[:q].strip}%"
        scope = scope.where("request_code ILIKE ? OR message_public ILIKE ?", query, query)
      end

      @total_demands = scope.count
      @demands = scope.limit(200).to_a
    end

    def demand_params
      params.require(:demand).permit(:triage_status, :notes, :assignee_id)
    end
  end
end
