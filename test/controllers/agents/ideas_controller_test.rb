require "test_helper"

module Agents
  class IdeasControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot moderate ideas" do
      sign_in users(:citizen)
      get agents_ideas_url
      assert_response :redirect
    end

    test "an agent updates an idea and notifies the author" do
      sign_in agents(:agent)
      idea = ideas(:compost)

      assert_difference -> { idea.user.notifications.count }, 1 do
        patch agents_idea_url(idea), params: { idea: { status: "under_review" } }
      end

      assert_redirected_to agents_idea_url(idea)
      assert_equal "under_review", idea.reload.status
    end
  end
end
