require "test_helper"

module Agents
  class ProjectsControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot manage projects" do
      sign_in users(:citizen)
      get agents_projects_url
      assert_response :redirect
    end

    test "an agent lists and creates a project" do
      sign_in agents(:agent)

      get agents_projects_url
      assert_response :success
      assert_match "Réaménagement du parc", response.body

      assert_difference -> { Project.count }, 1 do
        post agents_projects_url, params: {
          project: { name_fr: "Piste cyclable", name_en: "Cycle path",
                     category: "mobilite", status: "planned", published: "1" }
        }
      end

      assert_redirected_to agents_project_url(Project.order(:created_at).last)
    end

    test "an agent views, edits and deletes a project" do
      sign_in agents(:agent)
      project = projects(:park)

      get agents_project_url(project)
      assert_response :success

      get edit_agents_project_url(project)
      assert_response :success

      get new_agents_project_url
      assert_response :success

      patch agents_project_url(project), params: { project: { status: "completed" } }
      assert_redirected_to agents_project_url(project)
      assert_equal "completed", project.reload.status

      assert_difference -> { Project.count }, -1 do
        delete agents_project_url(project)
      end
    end

    test "an invalid project re-renders the form" do
      sign_in agents(:agent)

      assert_no_difference -> { Project.count } do
        post agents_projects_url, params: { project: { name_fr: "", category: "invalide" } }
      end
      assert_response :unprocessable_content
    end
  end
end
