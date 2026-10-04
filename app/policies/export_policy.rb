# frozen_string_literal: true

# Full data backup and export of the platform is restricted to administrators
# (F70/F87), so sensitive backups stay with the responsible teams.
class ExportPolicy < ApplicationPolicy
  def requests? = admin?

  private

  def admin?
    user.is_a?(Agent) && user.admin?
  end
end
