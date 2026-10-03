# frozen_string_literal: true

module Agents
  # Agent replies to citizen requests (F84).
  class RequestRepliesController < BaseController
    def create
      @request = Request.find_by!(reference: params[:request_id])
      authorize @request, :show?

      @reply = @request.request_replies.new(reply_params)
      @reply.created_by = current_agent
      authorize @reply, :create?

      if @reply.save
        notify_citizen(@request, @reply) unless @reply.internal?
        redirect_to agents_request_path(@request), notice: t("agents.request_replies.created")
      else
        redirect_to agents_request_path(@request), alert: t("agents.request_replies.invalid")
      end
    end

    private

    def reply_params
      params.require(:request_reply).permit(:body, :internal)
    end

    # A public reply notifies the citizen in-app and by email (F49/F84).
    def notify_citizen(request, reply)
      request.user.notifications.create!(
        kind: "reply",
        notifiable: request,
        title: t("notifications.reply.title", reference: request.reference),
        body: t("notifications.reply.body")
      )
      RequestMailer.replied(request, reply).deliver_later
    end
  end
end
