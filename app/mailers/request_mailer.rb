# frozen_string_literal: true

class RequestMailer < ApplicationMailer
  # Confirmation sent immediately after a citizen submits a request (D16).
  def submitted(request)
    @request = request
    @user = request.user
    mail(to: @user.email, subject: t("request_mailer.submitted.subject", reference: request.reference))
  end

  # Sent when an agent changes the status of a request (F49).
  def status_changed(request, event)
    @request = request
    @event = event
    @user = request.user
    mail(to: @user.email, subject: t("request_mailer.status_changed.subject", reference: request.reference))
  end
end
