require "test_helper"

module Demands
  class SyncTest < ActiveSupport::TestCase
    # Minimal stand-in for TerraNova::Webcup::Client.
    class FakeClient
      def initialize(*results)
        @results = results
      end

      def fetch_requests
        @results.shift
      end
    end

    def success_result(requests:, session: {})
      TerraNova::Webcup::Client::Result.new(
        success: true, http_status: 200, session: session, requests: requests
      )
    end

    def failure_result(error: "forbidden")
      TerraNova::Webcup::Client::Result.new(
        success: false, http_status: 403, error: error
      )
    end

    def demand_attrs(code, xp_available: 250)
      {
        "id" => 1, "request_code" => code, "requester_name" => "Haut Conseil",
        "requester_type" => "Institution", "message_public" => "A public demand",
        "difficulty" => "Facile", "difficulty_level" => 1,
        "xp_base" => 250, "xp_time_bonus" => 0, "xp_total" => 250,
        "xp_available" => xp_available,
        "is_initial" => true, "arrival_type" => "debut", "arrival_time" => ""
      }
    end

    test "imports demands and records the session" do
      client = FakeClient.new(
        success_result(requests: [ demand_attrs("T01") ], session: { "status" => "active", "current_wave" => 0 })
      )

      outcome = Demands::Sync.new(client: client).call

      assert outcome.sync.success?
      assert_equal [ "T01" ], outcome.new_codes
      assert_equal 0, outcome.sync.current_wave
      assert_equal "A public demand", Demand.find_by(request_code: "T01").message_public
    end

    test "is idempotent across polls and updates existing demands" do
      attrs = demand_attrs("T02")
      client = FakeClient.new(
        success_result(requests: [ attrs ]),
        success_result(requests: [ attrs.merge("xp_available" => 999) ])
      )

      first = Demands::Sync.new(client: client).call
      second = Demands::Sync.new(client: client).call

      assert_equal [ "T02" ], first.new_codes
      assert_empty second.new_codes
      assert_equal 1, Demand.where(request_code: "T02").count
      assert_equal 999, Demand.find_by(request_code: "T02").xp_available
    end

    test "records a failed sync and does not import anything" do
      client = FakeClient.new(failure_result)
      outcome = Demands::Sync.new(client: client).call

      assert_not outcome.sync.success?
      assert_equal "forbidden", outcome.sync.error
      assert_empty outcome.new_codes
    end

    test "detects newly arrived demands without duplicating seen ones" do
      client = FakeClient.new(
        success_result(requests: [ demand_attrs("T03") ]),
        success_result(requests: [ demand_attrs("T03"), demand_attrs("T04") ])
      )

      Demands::Sync.new(client: client).call
      outcome = Demands::Sync.new(client: client).call

      assert_equal [ "T04" ], outcome.new_codes
      assert_equal 2, Demand.where(request_code: %w[T03 T04]).count
    end
  end
end
