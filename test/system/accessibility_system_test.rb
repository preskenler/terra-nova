require "application_system_test_case"

class AccessibilitySystemTest < ApplicationSystemTestCase
  test "the homepage exposes landmarks, a skip link and the document language" do
    visit root_path

    assert_selector "html[lang='fr']"
    assert_selector "a[href='#main-content']"
    assert_selector "main#main-content"
    assert_selector "nav[aria-label]"
  end

  test "the contact form has programmatically labelled fields" do
    visit new_feedback_path

    assert_selector "label[for='feedback_subject']"
    assert_selector "label[for='feedback_message']"
    assert_selector "select#feedback_kind"
  end
end
