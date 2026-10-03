# frozen_string_literal: true

# Support / co-sign a citizen idea (F68).
class IdeaSupportsController < ApplicationController
  include CitizenSpace

  def create
    idea = Idea.find_by!(reference: params[:idea_id])
    idea.idea_supports.find_or_create_by!(user: current_user)
    redirect_to idea_path(idea), notice: t("ideas.supports.added")
  end

  def destroy
    idea = Idea.find_by!(reference: params[:idea_id])
    idea.idea_supports.where(user: current_user).destroy_all
    redirect_to idea_path(idea), notice: t("ideas.supports.removed")
  end
end
