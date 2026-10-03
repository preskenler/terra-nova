# frozen_string_literal: true

# Demands are part of the agent workspace only.
class DemandPolicy < ApplicationPolicy
  def index? = agent?
  def show? = agent?
  def update? = agent?
  def refresh? = agent?

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  private

  def agent?
    user.is_a?(Agent)
  end
end
