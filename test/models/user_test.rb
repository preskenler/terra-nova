require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "defaults to the citizen role" do
    assert users(:newcomer).citizen?
  end

  test "the admin? predicate reflects the role" do
    assert users(:admin).admin?
    assert_not users(:citizen).admin?
  end

  test "creating a user builds an associated profile" do
    user = User.create!(email: "fresh@example.com", password: "password123")
    assert user.profile.present?
  end

  test "a citizen has requests, appointments and notifications" do
    assert_respond_to users(:citizen), :requests
    assert_respond_to users(:citizen), :appointments
    assert_respond_to users(:citizen), :notifications
  end
end
