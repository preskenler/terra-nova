# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    @projects = Project.published.ordered.to_a
    @ongoing = @projects.select(&:ongoing?)
  end

  def show
    @project = Project.published.find_by!(slug: params[:id])
    @consultations = @project.consultations.recent_first
  end
end
