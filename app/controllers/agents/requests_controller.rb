# frozen_string_literal: true

module Agents
  # Agent handling of citizen requests (F22/D17/F49/F50/F75/F80).
  class RequestsController < BaseController
    include Pagination

    def index
      authorize Request

      # The "priority first" order surfaces what needs attention, especially as
      # the volume of daily requests grows (F86). It is also the default when the
      # agent is specifically looking at urgent requests.
      filtered_scope = filtered_requests
      scope = priority_sort? ? filtered_scope.priority_first : filtered_scope.recent_first

      @requests = paginate(scope).to_a
      @counts = Request.group(:status).count
      @pending_count = Request.open_requests.count
      @urgent_count = Request.urgent.open_requests.count
      @services = Service.order(:slug)

      respond_to do |format|
        format.html
        # Export the current selection (filters honoured) as a reusable CSV (F88).
        format.csv do
          send_data Requests::Csv.call(scope, detailed: true),
                    filename: "demandes-citoyens-#{Date.current}.csv",
                    type: "text/csv; charset=utf-8"
        end
      end
    end

    # Sets a request's priority (F80).
    def prioritize
      @request = Request.find_by!(reference: params[:id])
      authorize @request, :update?

      priority = params.dig(:request, :priority).presence || params[:priority]
      @request.update(priority: priority)
      redirect_to agents_request_path(@request), notice: t("agents.requests.priority_updated")
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

    # Applies the agent-visible filters shared by the list and the CSV export.
    def filtered_requests
      scope = Request.includes(:user, :service)
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where(priority: params[:priority]) if params[:priority].present?
      scope = scope.where(service_id: params[:service_id]) if params[:service_id].present?

      if params[:q].present?
        query = "%#{params[:q].strip}%"
        scope = scope.where(
          "reference LIKE :q OR subject LIKE :q OR description LIKE :q", q: query
        )
      end

      scope
    end

    # Urgent requests are put first by default, so what needs attention is
    # immediately visible as the volume grows (F86).
    def priority_sort?
      params[:sort] == "priority" || params[:priority] == "urgent"
    end

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
