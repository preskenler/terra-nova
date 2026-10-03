# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def index? = user.is_a?(Agent)
end
