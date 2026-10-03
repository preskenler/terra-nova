require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "reads the translated name" do
    project = projects(:park)
    assert_equal "Réaménagement du parc", I18n.with_locale(:fr) { project.name }
    assert_equal "Park redevelopment", I18n.with_locale(:en) { project.name }
  end

  test "generates a slug from the French name" do
    project = Project.new(name_fr: "Piste cyclable")
    project.validate
    assert_equal "piste-cyclable", project.slug
  end

  test "published scope hides drafts" do
    slugs = Project.published.map(&:slug)
    assert_includes slugs, "reamenagement-du-parc-central"
    assert_not_includes slugs, "projet-brouillon"
  end

  test "ongoing scope" do
    slugs = Project.ongoing.map(&:slug)
    assert_includes slugs, "reamenagement-du-parc-central"
    assert_not_includes slugs, "nouvelle-ligne-de-tram"
  end
end
