require "test_helper"

class Ui::PlainLanguageComponentTest < ViewComponent::TestCase
  test "renders a collapsed plain-language summary" do
    render_inline(Ui::PlainLanguageComponent.new(text: "Version simple du texte."))

    assert_selector "details summary", text: I18n.t("plain_language.title")
    assert_text "Version simple du texte."
  end

  test "renders nothing when there is no text" do
    render_inline(Ui::PlainLanguageComponent.new(text: ""))

    assert_no_selector "details"
  end
end
