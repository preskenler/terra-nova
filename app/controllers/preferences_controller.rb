# frozen_string_literal: true

# Accessibility preferences (high contrast, large text). Stored on the citizen
# profile when signed in, otherwise in the session.
class PreferencesController < ApplicationController
  def update
    high_contrast = params[:high_contrast] == "1"
    large_text = params[:large_text] == "1"

    session[:high_contrast] = high_contrast
    session[:large_text] = large_text

    current_user&.update(high_contrast: high_contrast, large_text: large_text)

    redirect_back fallback_location: root_path, notice: t("preferences.updated")
  end
end
