# frozen_string_literal: true

module Agents
  # Agents sign in on /agents/sign_in and must land in their own workspace, not
  # on the citizen homepage.
  class SessionsController < Devise::SessionsController
    private

    def after_sign_in_path_for(resource)
      resource.is_a?(Agent) ? agents_root_path : super
    end

    def after_sign_out_path_for(resource_or_scope)
      resource_or_scope == :agent ? new_agent_session_path : super
    end
  end
end
