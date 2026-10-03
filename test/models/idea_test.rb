require "test_helper"

class IdeaTest < ActiveSupport::TestCase
  test "generates a traceable reference" do
    idea = Idea.new(user: users(:citizen), title: "More trees", description: "Plant trees.")
    idea.validate
    assert_match(/\AIDEA-\d{4}-[A-Z0-9]{5}\z/, idea.reference)
  end

  test "requires a title and a description" do
    idea = Idea.new(user: users(:citizen))
    assert_not idea.valid?
    assert idea.errors[:title].any?
    assert idea.errors[:description].any?
  end

  test "support tracking" do
    idea = ideas(:compost)
    assert idea.supported_by?(users(:admin))
    assert_not idea.supported_by?(users(:citizen))
    assert_equal 1, idea.support_count
  end
end
