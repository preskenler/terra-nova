require "test_helper"

module Users
  class MagicLinkTest < ActiveSupport::TestCase
    test "a generated token signs the user in once" do
      user = users(:citizen)
      token = Users::MagicLink.generate(user)

      assert_equal user, Users::MagicLink.consume(token)
      assert_nil Users::MagicLink.consume(token), "token must be single-use"
    end

    test "a tampered token is rejected" do
      token = Users::MagicLink.generate(users(:citizen))
      assert_nil Users::MagicLink.consume("#{token}tampered")
    end
  end
end
