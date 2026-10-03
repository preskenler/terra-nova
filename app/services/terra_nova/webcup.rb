# frozen_string_literal: true

module TerraNova
  # Integration with the external Webcup "Terra Nova" API.
  #
  # The API is poll-based: the app calls it regularly and diffs the
  # +request_code+ values it returns. See TerraNova::Webcup::Client.
  module Webcup
    class << self
      def config
        Rails.application.config.x.webcup
      end

      def base_url
        config.base_url
      end

      def api_key
        config.api_key
      end

      def poll_interval
        config.poll_interval
      end

      def configured?
        api_key.present?
      end
    end
  end
end
