require "test_helper"

class Ui::BreadcrumbsComponentTest < ViewComponent::TestCase
  test "renders a labelled, ordered breadcrumb with the current page marked" do
    render_inline(Ui::BreadcrumbsComponent.new(items: [
      { label: "Home", path: "/" },
      { label: "Services", path: "/services" },
      { label: "Civil registry" }
    ]))

    assert_selector "nav[aria-label] ol li", count: 3
    assert_selector "[aria-current='page']", text: "Civil registry"
    assert_link "Services", href: "/services"
  end

  test "renders nothing without items" do
    render_inline(Ui::BreadcrumbsComponent.new(items: []))

    assert_no_selector "nav"
  end
end
