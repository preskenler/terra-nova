# frozen_string_literal: true

# Security monitoring is restricted to administrators (F69/F70).
class SecurityEventPolicy < ApplicationPolicy
  def index? = admin?

  private

  def admin?
    user.is_a?(Agent) && user.admin?
  end
end
