require "test_helper"

class Ui::AccessibilityControlsComponentTest < ViewComponent::TestCase
  test "submits outside Turbo so document accessibility attributes refresh" do
    render_inline(
      Ui::AccessibilityControlsComponent.new(
        high_contrast: false,
        large_text: false,
        reduced_data: false,
        simple_mode: false
      )
    )

    assert_selector "form[action='/preferences'][data-turbo='false']", visible: :all
  end
end
