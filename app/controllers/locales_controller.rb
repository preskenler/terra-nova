# frozen_string_literal: true

# Persists interface language for anonymous and signed-in users.
class LocalesController < ApplicationController
  def update
    locale = params[:locale].to_s

    if I18n.available_locales.map(&:to_s).include?(locale)
      session[:locale] = locale
      current_user&.update(locale: locale)
      current_agent&.update(locale: locale)
    end

    redirect_back fallback_location: root_path
  end
end
