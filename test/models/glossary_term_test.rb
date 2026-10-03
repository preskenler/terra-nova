require "test_helper"

class GlossaryTermTest < ActiveSupport::TestCase
  test "translated term and definition" do
    term = glossary_terms(:signalement)
    assert_equal "Signalement", I18n.with_locale(:fr) { term.term }
    assert_equal "Report", I18n.with_locale(:en) { term.term }
  end
end
