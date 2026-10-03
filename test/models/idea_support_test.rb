require "test_helper"

class IdeaSupportTest < ActiveSupport::TestCase
  test "a citizen can only support an idea once" do
    duplicate = IdeaSupport.new(idea: ideas(:compost), user: users(:admin))
    assert_not duplicate.valid?
    assert duplicate.errors[:user_id].any?
  end
end
