require "test_helper"

class Ui::PageHeaderComponentTest < ViewComponent::TestCase
  test "renders a title and optional subtitle" do
    render_inline(Ui::PageHeaderComponent.new(title: "Projects", subtitle: "Browse the city"))

    assert_selector "header.page-header h1.page-header-title", text: "Projects"
    assert_selector "p.page-header-subtitle", text: "Browse the city"
  end

  test "omits the subtitle when none is given" do
    render_inline(Ui::PageHeaderComponent.new(title: "Projects"))

    assert_selector "h1.page-header-title", text: "Projects"
    assert_no_selector "p.page-header-subtitle"
  end

  test "renders an actions block when content is given" do
    render_inline(Ui::PageHeaderComponent.new(title: "Projects")) { "New project" }

    assert_selector ".page-header-actions", text: "New project"
  end
end
