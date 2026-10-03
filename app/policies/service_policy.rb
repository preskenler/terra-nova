# frozen_string_literal: true

# Agents administer the municipal service catalog (F63).
class ServicePolicy < ApplicationPolicy
  def index?  = agent?
  def show?   = agent?
  def edit?   = agent?
  def update? = agent?
  def disable? = agent?
  def enable?  = agent?

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
