require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "index lists published projects and hides drafts" do
    get projects_url
    assert_response :success
    assert_match "Réaménagement du parc", response.body
    assert_no_match "Brouillon", response.body
  end

  test "show renders a project by its slug with its consultations" do
    get project_url(projects(:park))
    assert_response :success
    assert_match "Aire de jeux", response.body
  end
end
