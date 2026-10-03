# frozen_string_literal: true

module Agents
  # Shared base for the municipal agent workspace. Every route here requires an
  # authenticated Agent (protected at the routing level too), and authorization
  # is evaluated against the agent rather than the citizen User.
  class BaseController < ApplicationController
    before_action :authenticate_agent!
    layout "agents"

    # Pundit normally checks +current_user+; in the agent workspace the current
    # actor is the Agent.
    def pundit_user
      current_agent
    end
  end
end
