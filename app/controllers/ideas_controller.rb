# frozen_string_literal: true

class IdeasController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create ]

  def index
    @ideas = Idea.recent_first.to_a
  end

  def show
    @idea = Idea.find_by!(reference: params[:id])
    @supporting = current_user.present? && @idea.supported_by?(current_user)
  end

  def new
    @idea = current_user.ideas.new
  end

  def create
    @idea = current_user.ideas.new(idea_params)

    if @idea.save
      current_user.notifications.create!(
        kind: "general", notifiable: @idea,
        title: t("notifications.idea.title", reference: @idea.reference),
        body: t("notifications.idea.body")
      )
      redirect_to idea_path(@idea), notice: t("ideas.created", reference: @idea.reference)
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def idea_params
    params.require(:idea).permit(:title, :description, :category)
  end
end
