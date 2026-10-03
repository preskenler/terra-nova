# frozen_string_literal: true

module Agents
  # Agents administer citizen accounts (F34).
  class UsersController < BaseController
    def index
      authorize User

      scope = User.order(created_at: :desc)
      scope = scope.where("email LIKE ?", "%#{params[:q].strip}%") if params[:q].present?
      scope = scope.where(role: params[:role]) if params[:role].present?

      @users = scope.limit(200).to_a
    end

    def show
      @user = User.find(params[:id])
      authorize @user
    end

    def edit
      @user = User.find(params[:id])
      authorize @user
    end

    def update
      @user = User.find(params[:id])
      authorize @user

      attributes = params.require(:user).permit(:locale, :onboarding_completed)
      # Role changes are sensitive: only administrators may perform them, and
      # only for values known to the enum.
      if current_agent.admin? && User.roles.key?(params.dig(:user, :role))
        attributes[:role] = params[:user][:role]
      end

      if @user.update(attributes)
        redirect_to agents_user_path(@user), notice: t("agents.users.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    # Clears a lockout caused by repeated failed sign-ins (F37 support tool).
    def unlock
      @user = User.find(params[:id])
      authorize @user, :unlock?

      @user.unlock_access!
      redirect_to agents_user_path(@user), notice: t("agents.users.unlocked")
    end
  end
end
