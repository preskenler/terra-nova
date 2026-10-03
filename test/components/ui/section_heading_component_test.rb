require "test_helper"

class Ui::SectionHeadingComponentTest < ViewComponent::TestCase
  test "renders a section heading" do
    render_inline(Ui::SectionHeadingComponent.new(title: "Results"))

    assert_selector "h2", text: "Results"
  end

  test "keeps the given id for aria-labelledby" do
    render_inline(Ui::SectionHeadingComponent.new(title: "Results", id: "results-heading"))

    assert_selector "h2#results-heading", text: "Results"
  end
end
