# frozen_string_literal: true

# Enrol (or disable) two-factor authentication from the citizen profile (F53).
class TwoFactorSettingsController < ApplicationController
  include CitizenSpace

  skip_before_action :ensure_onboarding_complete

  def show
    current_user.generate_otp_secret!
    @qr_data_uri = qr_data_uri
  end

  def create
    current_user.generate_otp_secret!

    if current_user.verify_otp(params[:code])
      current_user.enable_two_factor!
      session[:otp_verified] = true
      redirect_to two_factor_settings_path, notice: t("two_factor.enabled")
    else
      @qr_data_uri = qr_data_uri
      flash.now[:alert] = t("two_factor.invalid_code")
      render :show, status: :unprocessable_content
    end
  end

  def destroy
    current_user.disable_two_factor!
    session[:otp_verified] = true
    redirect_to two_factor_settings_path, notice: t("two_factor.disabled")
  end

  private

  def qr_data_uri
    RQRCode::QRCode.new(current_user.otp_provisioning_uri).as_png(size: 240).to_data_url
  end
end
