require "test_helper"

class PartnerTest < ActiveSupport::TestCase
  test "reads the translated name" do
    partner = partners(:health)
    assert_equal "Centre Horizon", I18n.with_locale(:fr) { partner.name }
    assert_equal "Horizon Centre", I18n.with_locale(:en) { partner.name }
  end

  test "generates a slug" do
    partner = Partner.new(name_fr: "Club des sports")
    partner.validate
    assert_equal "club-des-sports", partner.slug
  end

  test "published hides drafts" do
    slugs = Partner.published.map(&:slug)
    assert_includes slugs, "centre-sante-horizon"
    assert_not_includes slugs, "partenaire-brouillon"
  end

  test "opening hours label" do
    partner = partners(:health)
    assert_equal "08:30 – 18:00", partner.hours_for(1).label
    assert_equal "Fermé", partner.hours_for(0).label
  end
end
