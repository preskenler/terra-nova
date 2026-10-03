# frozen_string_literal: true

module Users
  # Passwordless sign-in (D02): request a link, then consume it.
  class MagicLinksController < ApplicationController
    def new
    end

    def create
      email = params[:email].to_s.strip.downcase
      user = User.find_by(email: email)

      if user
        token = Users::MagicLink.generate(user)
        UserMailer.magic_link(user, users_magic_link_session_url(token: token)).deliver_later
      end

      # Generic message: do not reveal whether the email exists (anti-enumeration).
      redirect_to new_user_session_path, notice: t("magic_links.sent")
    end

    def show
      user = Users::MagicLink.consume(params[:token])

      if user
        sign_in(user)
        session[:otp_verified] = false
        redirect_to user.onboarding_completed? ? citizen_dashboard_path : onboarding_path,
                    notice: t("magic_links.signed_in")
      else
        redirect_to new_user_session_path, alert: t("magic_links.invalid")
      end
    end
  end
end
