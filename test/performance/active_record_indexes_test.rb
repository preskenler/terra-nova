require "test_helper"

# High-traffic columns are indexed so lists stay fast under load (F77/F78).
class ActiveRecordIndexesTest < ActiveSupport::TestCase
  test "performance-critical columns are indexed" do
    connection = ActiveRecord::Base.connection

    assert connection.index_exists?(:requests, :priority)
    assert connection.index_exists?(:requests, [ :user_id, :status ])
    assert connection.index_exists?(:demands, :last_seen_at)
    assert connection.index_exists?(:notifications, [ :user_id, :read_at ])
  end
end
