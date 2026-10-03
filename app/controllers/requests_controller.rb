# frozen_string_literal: true

# Citizen requests/signalements (F25/F26/D11/D16).
class RequestsController < ApplicationController
  include CitizenSpace
  include Pagination

  def index
    scope = current_user.requests

    if params[:status].present?
      scope = scope.where(status: params[:status])
    end

    if params[:q].present?
      query = "%#{params[:q].strip}%"
      scope = scope.where("subject ILIKE :q OR description ILIKE :q", q: query)
    end

    scope = params[:sort] == "oldest" ? scope.order(created_at: :asc) : scope.recent_first

    @all_requests = scope
    @requests = paginate(scope)
    @open_count = current_user.requests.open_requests.count

    respond_to do |format|
      format.html
      format.csv do
        send_data Requests::Csv.call(@all_requests),
                  filename: "mes-demandes-#{Date.current}.csv",
                  type: "text/csv; charset=utf-8"
      end
    end
  end

  def show
    @request = current_user.requests.find_by!(reference: params[:id])
    @events = @request.request_events.visible_to_citizens.chronological
    @supporting = @request.supported_by?(current_user)
  end

  def new
    @request = current_user.requests.new(
      service_id: params[:service_id],
      subject: params[:subject],
      description: params[:description]
    )
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
