require "test_helper"

class Ui::EmptyStateComponentTest < ViewComponent::TestCase
  test "renders the title and optional description" do
    render_inline(Ui::EmptyStateComponent.new(title: "Nothing here", description: "Try again"))

    assert_selector "p", text: "Nothing here"
    assert_selector "p", text: "Try again"
  end

  test "omits the description when none is given" do
    render_inline(Ui::EmptyStateComponent.new(title: "Nothing here"))

    assert_selector "p", text: "Nothing here"
    assert_no_selector "p", text: "Try again"
  end

  test "renders a content block when given" do
    render_inline(Ui::EmptyStateComponent.new(title: "Nothing here")) { "Act now" }

    assert_selector "div", text: "Act now"
  end
end
