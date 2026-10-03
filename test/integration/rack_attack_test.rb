require "test_helper"

# Brute-force protection is perceptible in real use (F37).
class RackAttackTest < ActionDispatch::IntegrationTest
  setup    { Rack::Attack.cache.store.clear }
  teardown { Rack::Attack.cache.store.clear }

  test "repeated sign-in attempts are throttled with 429" do
    statuses = Array.new(12) do
      post user_session_url, params: { user: { email: "victim@example.com", password: "wrong" } }
      response.status
    end

    assert_includes statuses, 429
  end
end
