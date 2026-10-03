# frozen_string_literal: true

# Agents administer citizen accounts (F34).
class UserPolicy < ApplicationPolicy
  def index? = agent?
  def show? = agent?
  def edit? = agent?
  def update? = agent?
  def unlock? = agent?

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
