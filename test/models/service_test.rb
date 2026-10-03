require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  test "reads the translated name for the current locale" do
    service = services(:etat_civil)
    assert_equal "État civil", I18n.with_locale(:fr) { service.name }
    assert_equal "Civil registry", I18n.with_locale(:en) { service.name }
  end

  test "falls back to the default locale when a translation is missing" do
    service = Service.new(slug: "dechets", name_fr: "Déchets")
    assert_equal "Déchets", I18n.with_locale(:en) { service.name }
  end

  test "generates a slug from the French name" do
    service = Service.new(name_fr: "Propreté urbaine", name_en: "Cleanliness")
    service.validate
    assert_equal "proprete-urbaine", service.slug
  end

  test "publicly_visible hides inactive services" do
    slugs = Service.publicly_visible.map(&:slug)
    assert_includes slugs, "etat-civil"
    assert_includes slugs, "eau"
    assert_not_includes slugs, "ferme"
  end

  test "priorities scope returns priority services only (F28)" do
    slugs = Service.priorities.map(&:slug)
    assert_includes slugs, "etat-civil"
    assert_not_includes slugs, "eau"
  end

  test "search matches translated content" do
    results = Service.publicly_visible.search("civil")
    assert_includes results.map(&:slug), "etat-civil"
  end

  test "status enum exposes maintenance and inactive predicates" do
    assert services(:water_maintenance).maintenance?
    assert services(:closed).inactive?
  end
end
