# frozen_string_literal: true

# Only municipal agents may post replies to a request (F84).
class RequestReplyPolicy < ApplicationPolicy
  def create? = agent?
  def show?   = agent? || (citizen? && !record.internal?)

  private

  def agent?   = user.is_a?(Agent)
  def citizen? = user.is_a?(User)
end
