require "test_helper"

class IdeaSupportsControllerTest < ActionDispatch::IntegrationTest
  test "a citizen can support and withdraw an idea" do
    sign_in users(:citizen)
    idea = ideas(:compost)

    assert_difference -> { IdeaSupport.count }, 1 do
      post idea_support_url(idea)
    end
    assert_redirected_to idea_url(idea)

    assert_difference -> { IdeaSupport.count }, -1 do
      delete idea_support_url(idea)
    end
  end
end
