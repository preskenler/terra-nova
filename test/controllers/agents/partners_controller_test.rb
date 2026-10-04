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

    test "an agent views, updates and deletes a partner" do
      sign_in agents(:agent)
      partner = partners(:health)

      get agents_partner_url(partner)
      assert_response :success

      get edit_agents_partner_url(partner)
      assert_response :success

      patch agents_partner_url(partner), params: { partner: { phone: "01 00 00 00 00" } }
      assert_redirected_to agents_partner_url(partner)

      assert_difference -> { Partner.count }, -1 do
        delete agents_partner_url(partner)
      end
    end

    test "an invalid partner re-renders the form" do
      sign_in agents(:agent)

      assert_no_difference -> { Partner.count } do
        post agents_partners_url, params: { partner: { name_fr: "", category: "invalide" } }
      end
      assert_response :unprocessable_content
    end
  end
end
