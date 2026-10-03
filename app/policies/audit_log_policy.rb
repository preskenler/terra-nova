# frozen_string_literal: true

class AuditLogPolicy < ApplicationPolicy
  def index? = agent?
  def show?  = agent?

  private

  def agent?
    user.is_a?(Agent)
  end
end
