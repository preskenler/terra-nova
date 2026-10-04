require "test_helper"

class GlossaryTermTest < ActiveSupport::TestCase
  test "translated term and definition" do
    term = glossary_terms(:signalement)
    assert_equal "Signalement", I18n.with_locale(:fr) { term.term }
    assert_equal "Report", I18n.with_locale(:en) { term.term }
  end

  test "generates a slug from the French term" do
    term = GlossaryTerm.new(term_fr: "Nouveau terme")
    term.validate

    assert_equal "nouveau-terme", term.slug
  end

  test "requires a term and uses the slug as parameter" do
    term = glossary_terms(:demarche)

    assert_equal "demarche", term.to_param
    assert_not GlossaryTerm.new(term_fr: "").valid?
  end
end
