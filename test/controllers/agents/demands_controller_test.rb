require "test_helper"

module Agents
  class DemandsControllerTest < ActionDispatch::IntegrationTest
    test "unauthenticated visitors are redirected to the agent sign-in" do
      get agents_demands_url
      assert_response :redirect
      assert_match "/agents/sign_in", response.location
    end

    test "citizens cannot reach the agent workspace" do
      sign_in users(:citizen)
      get agents_demands_url
      assert_response :redirect
      assert_match "/agents/sign_in", response.location
    end

    test "an agent sees the demand feed" do
      sign_in agents(:agent)
      get agents_demands_url
      assert_response :success
      assert_match "D01", response.body
      assert_match "F52", response.body
    end

    test "an agent can open a demand" do
      sign_in agents(:agent)
      get agents_demand_url(demands(:d01))
      assert_response :success
      assert_match "Haut Conseil", response.body
    end

    test "an agent can triage a demand" do
      sign_in agents(:agent)
      patch agents_demand_url(demands(:d01)),
            params: { demand: { triage_status: "in_progress", notes: "Being handled" } }

      assert_redirected_to agents_demand_url(demands(:d01))
      assert_equal "in_progress", demands(:d01).reload.triage_status
      assert_equal "Being handled", demands(:d01).notes
    end

    test "refresh returns a turbo stream" do
      sign_in agents(:agent)

      # Inject a client so the test never hits the network.
      fake = Object.new
      fake.define_singleton_method(:fetch_requests) do
        TerraNova::Webcup::Client::Result.new(
          success: true, http_status: 200,
          session: { "status" => "active", "current_wave" => 9 },
          requests: []
        )
      end

      original = Demands::Sync.client
      Demands::Sync.client = fake
      begin
        post refresh_agents_demands_url, headers: { "Accept" => "text/vnd.turbo-stream.html" }
      ensure
        Demands::Sync.client = original
      end

      assert_response :success
      assert_equal "text/vnd.turbo-stream.html", response.media_type
      assert_match "demands-summary", response.body
      assert_match "demands-list", response.body
    end
  end
end
