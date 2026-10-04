require "test_helper"

module Demands
  class SyncJobTest < ActiveSupport::TestCase
    test "the job triggers a demand sync" do
      called = false
      original = Demands::Sync.method(:call)
      Demands::Sync.define_singleton_method(:call) { |**| called = true }

      begin
        Demands::SyncJob.perform_now
        assert called
      ensure
        Demands::Sync.define_singleton_method(:call, original)
      end
    end
  end
end
