# frozen_string_literal: true

# Usage statistics are readable by any municipal agent (F98).
class StatisticsPolicy < ApplicationPolicy
  def index? = agent?

  private

  def agent?
    user.is_a?(Agent)
  end
end
