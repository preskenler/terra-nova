# frozen_string_literal: true

class FeedbackPolicy < ApplicationPolicy
  def new?    = true
  def create? = true
  def index?  = agent?
  def show?   = agent?
  def update? = agent?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user.is_a?(Agent) ? scope.all : scope.where(user_id: user&.id)
    end
  end

  private

  def agent?
    user.is_a?(Agent)
  end
end
