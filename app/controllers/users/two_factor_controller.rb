# frozen_string_literal: true

module Users
  # Second-factor challenge after a password / magic-link sign-in (F53).
  class TwoFactorController < ApplicationController
    before_action :authenticate_user!

    def show
    end

    def create
      if current_user.verify_otp(params[:code])
        session[:otp_verified] = true
        redirect_to citizen_dashboard_path, notice: t("two_factor.verified")
      else
        redirect_to users_two_factor_path, alert: t("two_factor.invalid_code")
      end
    end
  end
end
