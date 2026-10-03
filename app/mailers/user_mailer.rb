# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # Passwordless sign-in link (D02).
  def magic_link(user, url)
    @user = user
    @url = url
    mail(to: user.email, subject: t("user_mailer.magic_link.subject"))
  end

  # Security notice for a sign-in from a new device (F54).
  def new_sign_in(user, ip:, user_agent:)
    @user = user
    @ip = ip
    @user_agent = user_agent.to_s.first(120)
    @at = Time.current
    mail(to: user.email, subject: t("user_mailer.new_sign_in.subject"))
  end
end
