# frozen_string_literal: true

# Account deletion (F33). Requires the current password so an unauthorized
# person with an open session cannot delete the account silently.
class AccountsController < ApplicationController
  include CitizenSpace

  skip_before_action :ensure_onboarding_complete

  def show
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
