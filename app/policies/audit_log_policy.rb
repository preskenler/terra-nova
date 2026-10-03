# frozen_string_literal: true

# The audit trail is administrative data, restricted to administrators (F70).
class AuditLogPolicy < ApplicationPolicy
  def index? = admin?
  def show?  = admin?

  private

  def admin?
    user.is_a?(Agent) && user.admin?
  end
end
