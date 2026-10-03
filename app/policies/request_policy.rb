# frozen_string_literal: true

class RequestPolicy < ApplicationPolicy
  def index?  = agent? || citizen?
  def create? = citizen?
  def show?   = agent? || owner?
  def update? = agent?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.is_a?(Agent)
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def agent?
    user.is_a?(Agent)
  end

  def citizen?
    user.is_a?(User)
  end

  def owner?
    citizen? && record.respond_to?(:user_id) && record.user_id == user.id
  end
end
