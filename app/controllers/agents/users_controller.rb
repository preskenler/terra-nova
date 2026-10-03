# frozen_string_literal: true

module Agents
  # Agents administer citizen accounts (F34), including creating accounts for
  # residents without an email address (F71).
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
      @generated_credentials = flash[:generated_credentials]
    end

    def new
      @user = User.new
      authorize @user
    end

    # Creates a citizen account, even without an email address (F71).
    def create
      @user = User.new(citizen_params)
      authorize @user

      generated_email = @user.email.blank?
      @user.email = "resident-#{SecureRandom.hex(4)}@terra-nova.local" if generated_email
      @user.login_id ||= User.next_login_id
      temporary_password = SecureRandom.alphanumeric(10)
      @user.password = temporary_password
      @user.password_confirmation = temporary_password
      @user.role = :citizen

      if @user.save
        flash[:generated_credentials] = {
          login_id: @user.login_id,
          email: @user.email,
          password: temporary_password,
          generated_email: generated_email
        }
        redirect_to agents_user_path(@user), notice: t("agents.users.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      @user = User.find(params[:id])
      authorize @user
    end

    def update
      @user = User.find(params[:id])
      authorize @user

      attributes = params.require(:user).permit(:locale, :onboarding_completed)
      # Role changes are sensitive: administrators only, and only enum values.
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
      SecurityEvent.log("account_unlocked", actor: current_agent, metadata: { user_id: @user.id })
      redirect_to agents_user_path(@user), notice: t("agents.users.unlocked")
    end

    private

    def citizen_params
      params.require(:user).permit(:email, :login_id, :locale)
    end
  end
end
