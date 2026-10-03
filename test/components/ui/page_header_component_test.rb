require "test_helper"

class Ui::PageHeaderComponentTest < ViewComponent::TestCase
  test "renders a title and optional subtitle" do
    render_inline(Ui::PageHeaderComponent.new(title: "Projects", subtitle: "Browse the city"))

    assert_selector "header h1", text: "Projects"
    assert_selector "header p", text: "Browse the city"
  end

  test "omits the subtitle when none is given" do
    render_inline(Ui::PageHeaderComponent.new(title: "Projects"))

    assert_selector "h1", text: "Projects"
    assert_no_selector "header p"
  end

  test "renders an actions block when content is given" do
    render_inline(Ui::PageHeaderComponent.new(title: "Projects")) { "New project" }

    assert_selector "header", text: "New project"
  end
end
