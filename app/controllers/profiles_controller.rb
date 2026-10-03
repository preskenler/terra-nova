# frozen_string_literal: true

class ProfilesController < ApplicationController
  include CitizenSpace

  def show
    @profile = current_user.profile || current_user.create_profile
  end

  def edit
    @profile = current_user.profile || current_user.create_profile
  end

  def update
    @profile = current_user.profile || current_user.create_profile
    @profile.assign_attributes(profile_params)
    assign_preferences(current_user)

    if current_user.valid? && @profile.valid?
      current_user.save!
      @profile.save!
      redirect_to profile_path, notice: t("profiles.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.fetch(:profile, {}).permit(:address, :postal_code, :city, :phone)
  end
end
