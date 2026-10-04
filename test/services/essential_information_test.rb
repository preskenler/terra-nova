require "test_helper"

class EssentialInformationTest < ActiveSupport::TestCase
  test "always exposes the static emergency numbers" do
    info = EssentialInformation.call

    phones = info[:emergency_services].map { |s| s[:phone] }
    assert_includes phones, "112"
    assert_includes phones, "15"
    assert_equal false, info[:degraded]
  end

  test "includes priority procedures and current alerts" do
    info = EssentialInformation.call

    assert_includes info[:procedures].map { |p| p[:name] }, services(:etat_civil).name
    assert_operator info[:procedures].size, :<=, 4
    assert_not_empty info[:alerts]
  end

  test "degrades gracefully to the static essentials when the database fails" do
    original = Service.method(:publicly_visible)
    Service.define_singleton_method(:publicly_visible) { raise ActiveRecord::ConnectionNotEstablished }

    Rails.cache.delete(EssentialInformation::CACHE_KEY)
    info = EssentialInformation.call

    assert info[:degraded]
    assert_includes info[:emergency_services].map { |s| s[:phone] }, "112"
  ensure
    Service.define_singleton_method(:publicly_visible, original)
    Rails.cache.delete(EssentialInformation::CACHE_KEY)
  end
end
