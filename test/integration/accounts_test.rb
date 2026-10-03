require "test_helper"

class AccountsTest < ActionDispatch::IntegrationTest
  test "deletion requires the correct password" do
    sign_in users(:citizen)
    user_id = users(:citizen).id

    delete account_url, params: { password: "wrong-password" }

    assert_redirected_to account_url
    assert User.find_by(id: user_id).present?
  end

  test "deletion with the correct password removes the account" do
    sign_in users(:citizen)
    user_id = users(:citizen).id

    delete account_url, params: { password: "password123" }

    assert_redirected_to root_url
    assert_nil User.find_by(id: user_id)
  end
end
