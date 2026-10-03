# frozen_string_literal: true

module Demands
  # Background poll of the external Webcup API. Scheduled via Solid Queue
  # recurring tasks (see config/recurring.yml) and also triggerable from the
  # agent console.
  class SyncJob < ApplicationJob
    queue_as :default

    def perform
      Demands::Sync.call
    end
  end
end
