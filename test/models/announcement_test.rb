require "test_helper"

class AnnouncementTest < ActiveSupport::TestCase
  test "published scope only returns active, in-window announcements" do
    slugs = Announcement.published.map(&:id)
    assert_includes slugs, announcements(:info).id
    assert_not_includes slugs, announcements(:draft).id
  end

  test "reads translated title" do
    announcement = announcements(:info)
    assert_equal "Travaux place centrale", I18n.with_locale(:fr) { announcement.title }
    assert_equal "Central square works", I18n.with_locale(:en) { announcement.title }
  end

  test "audience_includes_citizens?" do
    assert announcements(:info).audience_includes_citizens?
  end
end
