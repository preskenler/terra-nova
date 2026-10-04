# frozen_string_literal: true

module Agents
  # Usage statistics of municipal services (F98). Accessible to agents; presents
  # a clear ranking rather than raw data.
  class StatisticsController < BaseController
    def index
      authorize :statistics, :index?

      @usage = Services::Usage.call(limit: 10)
    end
  end
end
