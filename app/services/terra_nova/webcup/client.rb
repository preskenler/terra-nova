# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module TerraNova
  module Webcup
    # Thin, dependency-free client for the external Webcup API.
    #
    # Authentication uses the +X-Webcup-Api-Key+ header (never a query string),
    # so the key does not leak into URLs or logs. The client is resilient: it
    # returns a Result instead of raising, distinguishing auth errors (403) from
    # network/timeout/server errors.
    class Client
      # Immutable-ish result object returned by #fetch_requests.
      class Result
        attr_reader :http_status, :session, :requests, :error

        def initialize(success:, http_status: nil, session: nil, requests: nil, error: nil)
          @success = success
          @http_status = http_status
          @session = session || {}
          @requests = requests || []
          @error = error
        end

        def success? = @success
        def failure? = !@success
      end

      def initialize(base_url: nil, api_key: nil, open_timeout: 5, read_timeout: 15)
        @base_url = (base_url.presence || TerraNova::Webcup.base_url).to_s.chomp("/")
        @api_key = api_key.presence || TerraNova::Webcup.api_key
        @open_timeout = open_timeout
        @read_timeout = read_timeout
      end

      # @return [Result]
      def fetch_requests
        return Result.new(success: false, error: "missing_api_key") if @api_key.blank?

        uri = URI.parse("#{@base_url}/requests")
        request = Net::HTTP::Get.new(uri)
        request["X-Webcup-Api-Key"] = @api_key
        request["Accept"] = "application/json"

        response = Net::HTTP.start(
          uri.hostname, uri.port,
          use_ssl: uri.scheme == "https",
          open_timeout: @open_timeout,
          read_timeout: @read_timeout
        ) { |http| http.request(request) }

        build_result(response)
      rescue Net::OpenTimeout, Net::ReadTimeout => e
        Result.new(success: false, error: "timeout: #{e.class}")
      rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SystemCallError => e
        Result.new(success: false, error: "network: #{e.class}")
      rescue URI::InvalidURIError => e
        Result.new(success: false, error: "invalid_url: #{e.message}")
      end

      private

      def build_result(response)
        status = response.code.to_i
        return Result.new(success: false, http_status: status, error: "forbidden") if status == 403
        return Result.new(success: false, http_status: status, error: "http_#{status}") unless response.is_a?(Net::HTTPSuccess)

        body = JSON.parse(response.body)
        Result.new(
          success: true,
          http_status: status,
          session: body["session"],
          requests: body["requests"]
        )
      rescue JSON::ParserError
        Result.new(success: false, http_status: status, error: "invalid_json")
      end
    end
  end
end
