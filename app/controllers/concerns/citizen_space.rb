# frozen_string_literal: true

# Shared behaviour for the citizen space: requires a signed-in User and forces
# first-time users through onboarding (D12/F35).
module CitizenSpace
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :ensure_onboarding_complete
  end

  private

  def ensure_onboarding_complete
    return if current_user.onboarding_completed?

    redirect_to onboarding_path, alert: t("onboarding.required")
  end

  # Applies the language + accessibility preferences submitted alongside a form.
  def assign_preferences(user)
    locale = params.dig(:user, :locale)
    if I18n.available_locales.map(&:to_s).include?(locale.to_s)
      user.locale = locale
    end
    user.high_contrast = params.dig(:user, :high_contrast) == "1"
    user.large_text = params.dig(:user, :large_text) == "1"
    user.reduced_data = params.dig(:user, :reduced_data) == "1"
    user.simple_mode = params.dig(:user, :simple_mode) == "1"
  end
end
