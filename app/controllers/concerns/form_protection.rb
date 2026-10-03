# frozen_string_literal: true

# Lightweight anti-automation protection for public forms (F81).
#
# Two complementary, non-intrusive checks:
#   1. A honeypot field ("website") that humans never fill in.
#   2. A signed token embedded at render time: a submission must carry a token
#      issued by the application, so blind scripted POSTs are rejected while
#      normal (fast) human submissions are unaffected.
#
# Blocks are recorded as SecurityEvent, so the protection is perceptible from
# the admin security console, and the visitor gets a clear message. Normal
# (human) use is unaffected.
module FormProtection
  extend ActiveSupport::Concern

  HONEYPOT_FIELD  = :website
  VERIFIER_PURPOSE = "form_protection"

  # Signed token embedding the render time; verified on submission.
  def self.form_protection_token
    verifier.generate(Time.current.to_i)
  end

  def self.verifier
    Rails.application.message_verifier(VERIFIER_PURPOSE)
  end

  private

  # before_action for public form submissions.
  def verify_human_submission!
    return if human_submission?

    SecurityEvent.log(
      "form_protection_blocked",
      request: request,
      actor: bot_actor,
      metadata: { controller: controller_path, action: action_name }
    )
    render "shared/blocked", status: :forbidden
  end

  def human_submission?
    return false if params[HONEYPOT_FIELD].present?

    valid_form_token?
  end

  def valid_form_token?
    FormProtection.verifier.verified(params[:form_token].to_s).is_a?(Integer)
  end

  def bot_actor
    return current_user if respond_to?(:current_user) && current_user
    return current_agent if respond_to?(:current_agent) && current_agent

    nil
  end
end
