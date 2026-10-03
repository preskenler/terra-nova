require "test_helper"

class Ui::SectionHeadingComponentTest < ViewComponent::TestCase
  test "renders a section heading with the accent wrapper" do
    render_inline(Ui::SectionHeadingComponent.new(title: "Results"))

    assert_selector ".section-heading h2.section-heading-title", text: "Results"
  end

  test "keeps the given id for aria-labelledby" do
    render_inline(Ui::SectionHeadingComponent.new(title: "Results", id: "results-heading"))

    assert_selector "h2#results-heading.section-heading-title", text: "Results"
  end
end
