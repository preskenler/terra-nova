# frozen_string_literal: true

# Support / co-sign an existing request (F52).
class RequestSupportsController < ApplicationController
  include CitizenSpace

  def create
    request = Request.find_by!(reference: params[:request_id])
    request.request_supports.find_or_create_by!(user: current_user)
    redirect_to request_path(request), notice: t("requests.supports.added")
  end

  def destroy
    request = Request.find_by!(reference: params[:request_id])
    request.request_supports.where(user: current_user).destroy_all
    redirect_to request_path(request), notice: t("requests.supports.removed")
  end
end
