require "test_helper"

class IdeasControllerTest < ActionDispatch::IntegrationTest
  test "index lists citizen ideas" do
    get ideas_url
    assert_response :success
    assert_match "More shared composters", response.body
  end

  test "the new idea form requires authentication" do
    get new_idea_url
    assert_response :redirect
  end

  test "creating an idea records it and notifies the author" do
    sign_in users(:citizen)

    assert_difference -> { Idea.count }, 1 do
      assert_difference -> { users(:citizen).notifications.count }, 1 do
        post ideas_url, params: { idea: { title: "More trees", description: "Plant more trees." } }
      end
    end

    assert_redirected_to idea_url(Idea.order(:created_at).last)
  end

  test "show renders an idea with its support action" do
    get idea_url(ideas(:compost))
    assert_response :success
    assert_match "More shared composters", response.body
    assert_match "Soutenir cette idée", response.body
  end
end
