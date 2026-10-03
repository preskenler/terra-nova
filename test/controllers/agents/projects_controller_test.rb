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
  end
end
