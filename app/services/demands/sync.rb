# frozen_string_literal: true

module Demands
  # Polls the external Webcup API and reconciles the +demands+ table.
  #
  # Idempotent: demands are keyed by the stable +request_code+, so repeated
  # polls (every 15-30s) never create duplicates. Each poll records a
  # +DemandSync+ row so the agent console can show session state and API health,
  # and newly arrived demands are announced live over Turbo Streams.
  class Sync
    Result = Struct.new(:sync, :new_codes, keyword_init: true)

    def self.call(**kwargs)
      new(**kwargs).call
    end

    class << self
      # Allows injecting a client (useful in tests and alternative environments).
      attr_writer :client

      def client
        @client ||= TerraNova::Webcup::Client.new
      end

      def reset_client!
        @client = nil
      end
    end

    def initialize(client: nil)
      @client = client || self.class.client
    end

    # @return [Result]
    def call
      result = @client.fetch_requests

      sync = DemandSync.create!(
        fetched_at: Time.current,
        success: result.success?,
        http_status: result.http_status,
        error: result.error,
        **session_attributes(result.session)
      )

      new_codes = result.success? ? import(result.requests) : []
      broadcast_count if new_codes.any?

      Result.new(sync: sync, new_codes: new_codes)
    end

    private

    def import(requests)
      new_codes = []

      requests.each do |attrs|
        code = attrs["request_code"].to_s
        next if code.blank?

        demand = Demand.find_or_initialize_by(request_code: code)
        if demand.new_record?
          demand.first_seen_at = Time.current
          new_codes << code
        end

        demand.assign_attributes(attributes_for(attrs))
        demand.last_seen_at = Time.current
        demand.save!
      end

      new_codes
    end

    def attributes_for(attrs)
      {
        external_id: attrs["id"],
        requester_name: attrs["requester_name"],
        requester_type: attrs["requester_type"],
        message_public: attrs["message_public"].to_s,
        difficulty: attrs["difficulty"],
        difficulty_level: attrs["difficulty_level"],
        xp_base: attrs["xp_base"],
        xp_time_bonus: attrs["xp_time_bonus"],
        xp_total: attrs["xp_total"],
        xp_available: attrs["xp_available"],
        is_initial: !!attrs["is_initial"],
        visible_since_wave: attrs["visible_since_wave"],
        arrival_type: attrs["arrival_type"],
        wave_number: attrs["wave_number"],
        arrival_time: attrs["arrival_time"].to_s,
        is_ai_related: !!attrs["is_ai_related"],
        is_ai_request: !!attrs["is_ai_request"],
        group_name: attrs["group_name"],
        sort_order: attrs["sort_order"],
        raw_payload: attrs
      }
    end

    def session_attributes(session)
      session = session || {}
      {
        status: session["status"],
        is_running: session.key?("is_running") ? !!session["is_running"] : nil,
        current_wave: session["current_wave"],
        elapsed_minutes: session["elapsed_minutes"],
        visible_requests_count: session["visible_requests_count"],
        initial_requests_count: session["initial_requests_count"],
        wave_requests_count: session["wave_requests_count"],
        next_wave_number: session["next_wave_number"],
        minutes_until_next_wave: session["minutes_until_next_wave"],
        raw_session: session
      }
    end

    # Live badge update for any agent currently on the console.
    def broadcast_count
      Turbo::StreamsChannel.broadcast_update_to(
        "agents_demands",
        target: "demand-unseen-count",
        html: Demand.new_arrivals.count.to_s
      )
    rescue StandardError => e
      Rails.logger.warn("Demand broadcast failed: #{e.class}: #{e.message}")
    end
  end
end
