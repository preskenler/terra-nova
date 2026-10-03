# frozen_string_literal: true

class IdeaPolicy < ApplicationPolicy
  def index?   = agent?
  def show?    = agent?
  def update?  = agent?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.is_a?(Agent) ? scope.all : scope.none
    end
  end

  private

  def agent?
    user.is_a?(Agent)
  end
end
