require "test_helper"

module Requests
  class SimilarityTest < ActiveSupport::TestCase
    test "returns no match when nothing is similar" do
      request = requests(:streetlight)

      assert_empty Requests::Similarity.new(request).call.select { |r| r.id == requests(:pothole).id }
    end

    test "finds a matching duplicate and boosts the same service" do
      base = Request.create!(user: users(:citizen), subject: "Broken fountain", description: "The fountain in the park is broken and leaks water.")
      duplicate = Request.create!(
        user: users(:citizen), service: base.service,
        subject: "Broken fountain", description: "The fountain in the park is broken and leaks water."
      )
      Request.create!(user: users(:citizen), subject: "Street noise", description: "Loud music at night downtown.")

      matches = Requests::Similarity.new(base).call

      assert_includes matches, duplicate
    end

    test "empty tokens score zero" do
      a = Request.new(subject: "a an", description: "the and")
      b = Request.new(subject: "a an", description: "the and")

      assert_empty Requests::Similarity.new(a).call
      assert_equal 0.0, Requests::Similarity.send(:new, a).send(:score, b)
    end
  end
end
