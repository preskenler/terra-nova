# frozen_string_literal: true

# Account deletion (F33). Requires the current password so an unauthorized
# person with an open session cannot delete the account silently.
class AccountsController < ApplicationController
  include CitizenSpace

  skip_before_action :ensure_onboarding_complete

  def show
  end

  # Clear, structured view of the data Nova Terra holds (F55).
  def data
    @data = UserDataExporter.new(current_user).as_json
    @recent_logins = current_user.login_activities.recent_first.limit(5)
  end

  # Download the data as a portable, readable JSON file (F55).
  def export
    payload = UserDataExporter.new(current_user).as_json
    send_data JSON.pretty_generate(payload),
              filename: "nova-terra-donnees-#{Date.current}.json",
              type: "application/json"
  end

  def destroy
    unless current_user.valid_password?(params[:password].to_s)
      return redirect_to account_path, alert: t("accounts.wrong_password")
    end

    user = current_user
    sign_out(user)
    user.destroy

    redirect_to root_path, notice: t("accounts.deleted")
  end
end
