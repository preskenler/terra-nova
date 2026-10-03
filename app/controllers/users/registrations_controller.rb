# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    private

    def after_sign_up_path_for(_resource)
      onboarding_path
    end

    def after_update_path_for(_resource)
      profile_path
    end
  end
end
