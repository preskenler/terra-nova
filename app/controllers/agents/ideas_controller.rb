# frozen_string_literal: true

module Agents
  # Moderate citizen ideas (F68).
  class IdeasController < BaseController
    before_action :set_idea, only: [ :show, :update ]

    def index
      authorize Idea
      @ideas = Idea.recent_first
    end

    def show
      authorize @idea
    end

    def update
      authorize @idea

      if @idea.update(idea_params)
        notify_author(@idea)
        redirect_to agents_idea_path(@idea), notice: t("agents.ideas.updated")
      else
        render :show, status: :unprocessable_content
      end
    end

    private

    def set_idea
      @idea = Idea.find_by!(reference: params[:id])
    end

    def idea_params
      params.require(:idea).permit(:status, :category)
    end

    def notify_author(idea)
      return if idea.user.blank?

      idea.user.notifications.create!(
        kind: "general", notifiable: idea,
        title: t("notifications.idea_status.title", reference: idea.reference),
        body: t("notifications.idea_status.body", status: t("ideas.status.#{idea.status}"))
      )
    end
  end
end
