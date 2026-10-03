# frozen_string_literal: true

module Agents
  # Manage municipal projects (F67).
  class ProjectsController < BaseController
    before_action :set_project, only: [ :show, :edit, :update, :destroy ]

    def index
      authorize Project
      @projects = Project.ordered
    end

    def show
      authorize @project
      @consultations = @project.consultations.recent_first
    end

    def new
      @project = Project.new(published: true)
      authorize @project
    end

    def create
      @project = Project.new(project_params)
      authorize @project

      if @project.save
        redirect_to agents_project_path(@project), notice: t("agents.projects.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def edit
      authorize @project
    end

    def update
      authorize @project

      if @project.update(project_params)
        redirect_to agents_project_path(@project), notice: t("agents.projects.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      authorize @project
      @project.destroy
      redirect_to agents_projects_path, notice: t("agents.projects.destroyed")
    end

    private

    def set_project
      @project = Project.find_by!(slug: params[:id])
    end

    def project_params
      params.require(:project).permit(
        :status, :category, :starts_on, :ends_on, :published,
        :name_fr, :name_en, :description_fr, :description_en
      )
    end
  end
end
