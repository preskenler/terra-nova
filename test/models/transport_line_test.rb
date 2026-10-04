require "test_helper"

class TransportLineTest < ActiveSupport::TestCase
  test "translated name and mode" do
    line = transport_lines(:tram)
    assert_equal "Tram T1", I18n.with_locale(:fr) { line.name }
    assert line.tram?
  end

  test "current_disruptions excludes ended disruptions" do
    line = transport_lines(:bus)
    line.transport_disruptions.create!(
      message_fr: "Travaux", message_en: "Works",
      severity: "warning", ends_at: 1.day.from_now
    )
    line.transport_disruptions.create!(
      message_fr: "Terminé", message_en: "Over",
      severity: "info", ends_at: 1.day.ago
    )
    assert_equal 1, line.current_disruptions.count
  end

  test "generates a slug and exposes ordered/active scopes" do
    line = TransportLine.new(name_fr: "Bus express", mode: "bus")
    line.validate

    assert_equal "bus-express", line.slug
    assert_equal "tram-t1", transport_lines(:tram).to_param
    assert_includes TransportLine.active, transport_lines(:bus)
    assert_not_includes TransportLine.active, transport_lines(:tram).tap { |l| l.update!(active: false) }
  end
end
