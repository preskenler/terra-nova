# frozen_string_literal: true

# First-login onboarding (D12/F35): complete the profile, choose a language,
# set accessibility preferences, then land in the personal space.
class OnboardingController < ApplicationController
  include CitizenSpace

  skip_before_action :ensure_onboarding_complete

  def show
    @profile = current_user.profile || current_user.create_profile
  end

  def update
    @profile = current_user.profile || current_user.create_profile
    @profile.assign_attributes(profile_params)
    assign_preferences(current_user)
    current_user.onboarding_completed = true

    if current_user.valid? && @profile.valid?
      current_user.save!
      @profile.save!
      redirect_to citizen_dashboard_path, notice: t("onboarding.completed")
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.fetch(:profile, {}).permit(:address, :postal_code, :city, :phone)
  end
end
