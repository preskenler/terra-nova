# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    private

    # First-time citizens go through onboarding before reaching their space.
    def after_sign_in_path_for(resource)
      return onboarding_path unless resource.onboarding_completed?

      stored_location_for(resource) || citizen_dashboard_path
    end
  end
end
