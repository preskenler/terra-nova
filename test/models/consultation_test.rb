require "test_helper"

class ConsultationTest < ActiveSupport::TestCase
  test "open_for_response? reflects status and dates" do
    assert consultations(:park_opinion).open_for_response?
    assert_not consultations(:closed_survey).open_for_response?
  end

  test "responded_by? detects a citizen's answer" do
    consultation = consultations(:park_opinion)
    assert consultation.responded_by?(users(:admin))
    assert_not consultation.responded_by?(users(:citizen))
  end

  test "open_now excludes closed consultations" do
    ids = Consultation.open_now.map(&:id)
    assert_includes ids, consultations(:park_opinion).id
    assert_not_includes ids, consultations(:closed_survey).id
  end
end
