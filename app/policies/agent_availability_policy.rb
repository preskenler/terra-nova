# frozen_string_literal: true

class AgentAvailabilityPolicy < ApplicationPolicy
  def index?   = agent?
  def new?     = create?
  def create?  = agent?
  def destroy? = agent? && record.respond_to?(:agent_id) && record.agent_id == user.id

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(Agent)
        scope.where(agent_id: user.id)
      else
        scope.none
      end
    end
  end

  private

  def agent?
    user.is_a?(Agent)
  end
end
