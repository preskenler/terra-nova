# frozen_string_literal: true

class AlertPolicy < ApplicationPolicy
  def index?   = agent?
  def show?    = agent?
  def new?     = create?
  def create?  = agent?
  def edit?    = update?
  def update?  = agent?
  def destroy? = agent?

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
