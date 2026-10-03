require "test_helper"

class DemandSyncTest < ActiveSupport::TestCase
  test "latest returns the most recent successful snapshot" do
    sync = DemandSync.latest
    assert sync.present?
    assert_equal 9, sync.current_wave
  end
end
