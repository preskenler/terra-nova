class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_audit_actor
  before_action :require_otp_verification

  around_action :switch_locale

  helper_method :current_locale, :high_contrast?, :large_text?, :reduced_data?, :simple_mode?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Records who made each audited change (F47/F48). Stored as "Agent:<id>" or
  # "User:<id>" so the audit log can resolve the actor.
  def set_audit_actor
    PaperTrail.request.whodunnit = audit_actor
  end

  def audit_actor
    return "Agent:#{current_agent.id}" if respond_to?(:current_agent) && current_agent
    return "User:#{current_user.id}" if respond_to?(:current_user) && current_user

    "system"
  end

  # Enforces the second factor after a password/magic-link sign-in (F53).
  def require_otp_verification
    return unless current_user&.otp_enabled?
    return if session[:otp_verified]

    allowed = %w[
      users/two_factor users/sessions users/magic_links
      users/registrations users/passwords
    ]
    return if allowed.include?(controller_path)

    redirect_to users_two_factor_path
  end

  # Locale resolution order: explicit param -> signed-in preference -> session
  # -> cookie -> default. Keeps the language stable across the whole app.
  def switch_locale(&action)
    I18n.with_locale(current_locale, &action)
  end

  def current_locale
    @current_locale ||= resolve_locale
  end

  def resolve_locale
    candidate = (params[:locale].presence || signed_in_locale || session[:locale] || cookies[:locale]).to_s
    I18n.available_locales.map(&:to_s).include?(candidate) ? candidate.to_sym : I18n.default_locale
  end

  def signed_in_locale
    return current_user.locale if current_user&.locale.present?
    return current_agent.locale if current_agent&.locale.present?

    nil
  end

  # Accessibility preferences live on the User profile when signed in, and fall
  # back to the session for anonymous visitors (or agents).
  def high_contrast?
    accessibility_preference(:high_contrast)
  end

  def large_text?
    accessibility_preference(:large_text)
  end

  # Low-data mode: skips heavy optional resources (map tiles) (F59).
  # Simple mode implies low-data mode, and also renders lighter pages (F62).
  def reduced_data?
    simple_mode? || accessibility_preference(:reduced_data)
  end

  # Simple mode: a lighter, faster rendering of key pages (F62).
  def simple_mode?
    accessibility_preference(:simple_mode)
  end

  def accessibility_preference(attribute)
    record = current_user
    if record && record.respond_to?(attribute)
      record.public_send(attribute)
    else
      ActiveModel::Type::Boolean.new.cast(session[attribute])
    end
  end

  def user_not_authorized
    respond_to do |format|
      format.html { redirect_back fallback_location: root_path, alert: t("errors.not_authorized") }
      format.any  { head :forbidden }
    end
  end
end
