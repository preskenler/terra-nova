# frozen_string_literal: true

module Agents
  # Agent handling of citizen requests (F22/D17/F49/F50).
  class RequestsController < BaseController
    def index
      authorize Request

      scope = Request.includes(:user, :service).recent_first
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where(service_id: params[:service_id]) if params[:service_id].present?

      if params[:q].present?
        query = "%#{params[:q].strip}%"
        scope = scope.where(
          "reference LIKE :q OR subject LIKE :q OR description LIKE :q", q: query
        )
      end

      @requests = scope.limit(200).to_a
      @counts = Request.group(:status).count
      @pending_count = Request.open_requests.count
      @services = Service.order(:slug)
    end

    def show
      @request = Request.find_by!(reference: params[:id])
      authorize @request
      @events = @request.request_events.chronological
      @event = @request.request_events.new(to_status: @request.status)
      @similar_requests = Requests::Similarity.new(@request).call
    end

    # Links this request to the request it duplicates (F75).
    def link_duplicate
      @request = Request.find_by!(reference: params[:id])
      authorize @request

      duplicate = Request.find_by!(reference: params[:duplicate_reference])
      @request.update!(duplicate_of: duplicate)
      redirect_to agents_request_path(@request), notice: t("agents.requests.duplicate_linked")
    end

    def update
      @request = Request.find_by!(reference: params[:id])
      authorize @request

      attributes = event_params
      new_status = attributes[:to_status].presence || @request.status
      @event = @request.request_events.new(
        from_status: @request.status,
        to_status: new_status,
        comment: attributes[:comment],
        visible_to_citizen: attributes[:visible_to_citizen],
        created_by: current_agent
      )
      @request.status = new_status

      ActiveRecord::Base.transaction do
        @request.save!
        @event.save!
      end

      notify_citizen(@request, @event)
      redirect_to agents_request_path(@request), notice: t("agents.requests.updated")
    rescue ActiveRecord::RecordInvalid
      @events = @request.request_events.chronological
      render :show, status: :unprocessable_content
    end

    private

    def event_params
      params.require(:request_event).permit(:to_status, :comment, :visible_to_citizen)
    end

    # Citizen-visible status changes create an in-app notification and an email (F49).
    def notify_citizen(request, event)
      return unless event.visible_to_citizen?

      request.user.notifications.create!(
        kind: "status_change",
        notifiable: request,
        title: t("notifications.status_change.title", reference: request.reference),
        body: t("notifications.status_change.body", status: t("requests.status.#{request.status}"))
      )
      RequestMailer.status_changed(request, event).deliver_later
    end
  end
end
