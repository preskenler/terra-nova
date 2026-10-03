require "test_helper"

module Agents
  class PartnersControllerTest < ActionDispatch::IntegrationTest
    test "citizens cannot manage partners" do
      sign_in users(:citizen)
      get agents_partners_url
      assert_response :redirect
    end

    test "an agent creates a partner and updates its hours" do
      sign_in agents(:agent)

      assert_difference -> { Partner.count }, 1 do
        post agents_partners_url, params: {
          partner: { name_fr: "Club des sports", name_en: "Sports club", category: "sport", published: "1" }
        }
      end

      partner = Partner.order(:created_at).last
      assert_redirected_to agents_partner_url(partner)

      patch hours_agents_partner_url(partner),
            params: { opening_hours: { "1" => { opens_at: "09:00", closes_at: "17:00" } } }

      assert_equal "09:00", partner.reload.hours_for(1).opens_at
    end
  end
end
