require "test_helper"
require "net/http"

module TerraNova
  module Webcup
    class ClientTest < ActiveSupport::TestCase
      def with_response(response)
        original = Net::HTTP.method(:start)
        Net::HTTP.define_singleton_method(:start) { |*_args, &_blk| response }
        yield
      ensure
        Net::HTTP.define_singleton_method(:start, original)
      end

      def http_response(code, body)
        klass = case code
        when 200 then Net::HTTPSuccess
        when 403 then Net::HTTPForbidden
        else Net::HTTPInternalServerError
        end
        klass.new("1.1", code.to_s, "").tap do |r|
          r.instance_variable_set(:@body, body)
          r.instance_variable_set(:@read, true)
        end
      end

      def without_api_key
        original = TerraNova::Webcup.config.api_key
        TerraNova::Webcup.config.api_key = nil
        yield
      ensure
        TerraNova::Webcup.config.api_key = original
      end

      test "missing api key fails fast without an HTTP call" do
        without_api_key do
          result = Client.new(api_key: "", base_url: "https://example.test").fetch_requests

          assert result.failure?
          assert_equal "missing_api_key", result.error
        end
      end

      test "a successful response exposes session and requests" do
        body = { "session" => { "current_wave" => 3 }, "requests" => [ { "request_code" => "F1" } ] }.to_json

        with_response(http_response(200, body)) do
          result = Client.new(api_key: "key").fetch_requests

          assert result.success?
          assert_equal 200, result.http_status
          assert_equal 3, result.session["current_wave"]
          assert_equal "F1", result.requests.first["request_code"]
        end
      end

      test "403 is reported as forbidden" do
        with_response(http_response(403, "")) do
          result = Client.new(api_key: "key").fetch_requests

          assert result.failure?
          assert_equal "forbidden", result.error
          assert_equal 403, result.http_status
        end
      end

      test "a 500 is reported as an http error" do
        with_response(http_response(500, "boom")) do
          result = Client.new(api_key: "key").fetch_requests

          assert result.failure?
          assert_equal "http_500", result.error
        end
      end

      test "invalid JSON is reported" do
        with_response(http_response(200, "not json")) do
          result = Client.new(api_key: "key").fetch_requests

          assert result.failure?
          assert_equal "invalid_json", result.error
        end
      end

      test "timeouts are rescued" do
        original = Net::HTTP.method(:start)
        Net::HTTP.define_singleton_method(:start) { |*_a, **_k| raise Net::ReadTimeout }
        begin
          result = Client.new(api_key: "key", read_timeout: 1).fetch_requests
          assert result.failure?
          assert_match "timeout", result.error
        ensure
          Net::HTTP.define_singleton_method(:start, original)
        end
      end

      test "network errors are rescued" do
        original = Net::HTTP.method(:start)
        Net::HTTP.define_singleton_method(:start) { |*_a, **_k| raise SocketError }
        begin
          result = Client.new(api_key: "key").fetch_requests
          assert result.failure?
          assert_match "network", result.error
        ensure
          Net::HTTP.define_singleton_method(:start, original)
        end
      end

      test "an invalid URL is reported" do
        result = Client.new(api_key: "key", base_url: "http://exa mple").fetch_requests

        assert result.failure?
        assert_match "invalid_url", result.error
      end
    end
  end
end
