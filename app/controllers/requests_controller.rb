# frozen_string_literal: true

# Citizen requests/signalements (F25/F26/D11/D16).
class RequestsController < ApplicationController
  include CitizenSpace

  def index
    @requests = current_user.requests.recent_first
    @open_count = current_user.requests.open_requests.count
  end

  def show
    @request = current_user.requests.find_by!(reference: params[:id])
    @events = @request.request_events.visible_to_citizens.chronological
    @supporting = @request.supported_by?(current_user)
  end

  def new
    @request = current_user.requests.new(service_id: params[:service_id])
    @services = Service.publicly_visible.ordered
  end

  def create
    @request = current_user.requests.new(request_params)

    if @request.save
      @request.request_events.create!(
        to_status: @request.status,
        comment: t("requests.events.submitted"),
        created_by: current_user,
        visible_to_citizen: true
      )
      RequestMailer.submitted(@request).deliver_later
      redirect_to request_path(@request),
                  notice: t("requests.created_notice", reference: @request.reference)
    else
      @services = Service.publicly_visible.ordered
      render :new, status: :unprocessable_content
    end
  end

  private

  def request_params
    params.require(:request).permit(
      :service_id, :subject, :description, :location_text, :latitude, :longitude
    )
  end
end
