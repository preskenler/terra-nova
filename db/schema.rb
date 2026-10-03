# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_04_010000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "agent_availabilities", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.integer "wday", null: false
    t.time "start_time", null: false
    t.time "end_time", null: false
    t.integer "slot_minutes", default: 30, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_agent_availabilities_on_agent_id"
  end

  create_table "agent_time_offs", force: :cascade do |t|
    t.bigint "agent_id", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id", "starts_at"], name: "index_agent_time_offs_on_agent_id_and_starts_at"
    t.index ["agent_id"], name: "index_agent_time_offs_on_agent_id"
  end

  create_table "agents", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "role", default: "agent", null: false
    t.string "locale", default: "fr", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_agents_on_email", unique: true
    t.index ["reset_password_token"], name: "index_agents_on_reset_password_token", unique: true
    t.index ["role"], name: "index_agents_on_role"
    t.index ["unlock_token"], name: "index_agents_on_unlock_token", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.json "title_translations"
    t.json "body_translations"
    t.string "kind", default: "other", null: false
    t.string "severity", default: "alert", null: false
    t.string "target_segment", default: "all", null: false
    t.string "locality"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.decimal "radius_km", precision: 8, scale: 2
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_alerts_on_active"
    t.index ["kind"], name: "index_alerts_on_kind"
  end

  create_table "announcements", force: :cascade do |t|
    t.json "title_translations"
    t.json "body_translations"
    t.string "severity", default: "info", null: false
    t.string "target_audience", default: "all", null: false
    t.datetime "published_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "pinned", default: false, null: false
    t.index ["active"], name: "index_announcements_on_active"
    t.index ["pinned"], name: "index_announcements_on_pinned"
    t.index ["severity"], name: "index_announcements_on_severity"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "agent_id", null: false
    t.bigint "service_id"
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "duration_minutes", default: 30, null: false
    t.text "notes"
    t.string "status", default: "confirmed", null: false
    t.string "cancellation_reason"
    t.datetime "reminder_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_appointments_on_agent_id"
    t.index ["service_id"], name: "index_appointments_on_service_id"
    t.index ["starts_at"], name: "index_appointments_on_starts_at"
    t.index ["status"], name: "index_appointments_on_status"
    t.index ["user_id"], name: "index_appointments_on_user_id"
  end

  create_table "consultation_responses", force: :cascade do |t|
    t.bigint "consultation_id", null: false
    t.bigint "user_id", null: false
    t.string "choice", null: false
    t.text "comment"
    t.string "reference", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["consultation_id", "user_id"], name: "index_consultation_responses_on_consultation_and_user", unique: true
    t.index ["consultation_id"], name: "index_consultation_responses_on_consultation_id"
    t.index ["reference"], name: "index_consultation_responses_on_reference", unique: true
    t.index ["user_id"], name: "index_consultation_responses_on_user_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.bigint "project_id"
    t.json "title_translations"
    t.json "description_translations"
    t.string "kind", default: "opinion", null: false
    t.string "status", default: "draft", null: false
    t.datetime "opens_at"
    t.datetime "closes_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_consultations_on_project_id"
    t.index ["status"], name: "index_consultations_on_status"
  end

  create_table "demand_syncs", force: :cascade do |t|
    t.datetime "fetched_at", null: false
    t.boolean "success", default: false, null: false
    t.integer "http_status"
    t.text "error"
    t.string "status"
    t.boolean "is_running"
    t.integer "current_wave"
    t.integer "elapsed_minutes"
    t.integer "visible_requests_count"
    t.integer "initial_requests_count"
    t.integer "wave_requests_count"
    t.integer "next_wave_number"
    t.integer "minutes_until_next_wave"
    t.json "raw_session"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fetched_at"], name: "index_demand_syncs_on_fetched_at"
    t.index ["success"], name: "index_demand_syncs_on_success"
  end

  create_table "demands", force: :cascade do |t|
    t.string "request_code", null: false
    t.integer "external_id"
    t.string "requester_name"
    t.string "requester_type"
    t.text "message_public"
    t.string "difficulty"
    t.integer "difficulty_level"
    t.integer "xp_base"
    t.integer "xp_time_bonus"
    t.integer "xp_total"
    t.integer "xp_available"
    t.boolean "is_initial", default: false, null: false
    t.integer "visible_since_wave"
    t.string "arrival_type"
    t.integer "wave_number"
    t.string "arrival_time"
    t.boolean "is_ai_related", default: false, null: false
    t.boolean "is_ai_request", default: false, null: false
    t.string "group_name"
    t.integer "sort_order"
    t.string "triage_status", default: "unseen", null: false
    t.text "notes"
    t.bigint "assignee_id"
    t.datetime "first_seen_at"
    t.datetime "last_seen_at"
    t.json "raw_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_demands_on_assignee_id"
    t.index ["difficulty_level"], name: "index_demands_on_difficulty_level"
    t.index ["last_seen_at"], name: "index_demands_on_last_seen_at"
    t.index ["request_code"], name: "index_demands_on_request_code", unique: true
    t.index ["triage_status"], name: "index_demands_on_triage_status"
    t.index ["wave_number"], name: "index_demands_on_wave_number"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "user_id"
    t.string "kind", default: "question", null: false
    t.string "email"
    t.string "subject", null: false
    t.text "message", null: false
    t.string "status", default: "new", null: false
    t.text "agent_notes"
    t.string "reference", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind"], name: "index_feedbacks_on_kind"
    t.index ["reference"], name: "index_feedbacks_on_reference", unique: true
    t.index ["status"], name: "index_feedbacks_on_status"
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "glossary_terms", force: :cascade do |t|
    t.string "slug", null: false
    t.json "term_translations"
    t.json "definition_translations"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_glossary_terms_on_slug", unique: true
  end

  create_table "idea_supports", force: :cascade do |t|
    t.bigint "idea_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["idea_id", "user_id"], name: "index_idea_supports_on_idea_id_and_user_id", unique: true
    t.index ["idea_id"], name: "index_idea_supports_on_idea_id"
    t.index ["user_id"], name: "index_idea_supports_on_user_id"
  end

  create_table "ideas", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "reference", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.string "category"
    t.string "status", default: "submitted", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_ideas_on_reference", unique: true
    t.index ["status"], name: "index_ideas_on_status"
    t.index ["user_id"], name: "index_ideas_on_user_id"
  end

  create_table "login_activities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip"
    t.string "user_agent", limit: 255
    t.string "fingerprint", limit: 64
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_login_activities_on_created_at"
    t.index ["user_id", "fingerprint"], name: "index_login_activities_on_user_id_and_fingerprint"
    t.index ["user_id"], name: "index_login_activities_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type"
    t.bigint "notifiable_id"
    t.string "kind", default: "general", null: false
    t.string "title", null: false
    t.text "body"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["read_at"], name: "index_notifications_on_read_at"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "partner_opening_hours", force: :cascade do |t|
    t.bigint "partner_id", null: false
    t.integer "wday", null: false
    t.string "opens_at"
    t.string "closes_at"
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id", "wday"], name: "index_partner_opening_hours_on_partner_id_and_wday", unique: true
    t.index ["partner_id"], name: "index_partner_opening_hours_on_partner_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "slug", null: false
    t.json "name_translations"
    t.json "description_translations"
    t.string "category"
    t.string "address"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "phone"
    t.string "website"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_partners_on_category"
    t.index ["slug"], name: "index_partners_on_slug", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address"
    t.string "postal_code"
    t.string "city"
    t.string "phone"
    t.json "preferences"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "slug", null: false
    t.json "name_translations"
    t.json "description_translations"
    t.string "category"
    t.string "status", default: "planned", null: false
    t.date "starts_on"
    t.date "ends_on"
    t.boolean "published", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_projects_on_slug", unique: true
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "request_events", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.string "from_status"
    t.string "to_status", null: false
    t.text "comment"
    t.boolean "visible_to_citizen", default: true, null: false
    t.string "created_by_type"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_type", "created_by_id"], name: "index_request_events_on_created_by"
    t.index ["request_id"], name: "index_request_events_on_request_id"
  end

  create_table "request_supports", force: :cascade do |t|
    t.bigint "request_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id", "user_id"], name: "index_request_supports_on_request_id_and_user_id", unique: true
    t.index ["request_id"], name: "index_request_supports_on_request_id"
    t.index ["user_id"], name: "index_request_supports_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "service_id"
    t.string "reference", null: false
    t.string "subject", null: false
    t.text "description", null: false
    t.string "location_text"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "status", default: "submitted", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "duplicate_of_id"
    t.string "priority", default: "normal", null: false
    t.index ["duplicate_of_id"], name: "index_requests_on_duplicate_of_id"
    t.index ["priority"], name: "index_requests_on_priority"
    t.index ["reference"], name: "index_requests_on_reference", unique: true
    t.index ["service_id"], name: "index_requests_on_service_id"
    t.index ["status"], name: "index_requests_on_status"
    t.index ["user_id", "status"], name: "index_requests_on_user_id_and_status"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "security_events", force: :cascade do |t|
    t.string "event", null: false
    t.string "actor_type"
    t.bigint "actor_id"
    t.string "ip"
    t.string "user_agent", limit: 255
    t.json "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_type", "actor_id"], name: "index_security_events_on_actor"
    t.index ["created_at"], name: "index_security_events_on_created_at"
    t.index ["event"], name: "index_security_events_on_event"
  end

  create_table "service_reviews", force: :cascade do |t|
    t.bigint "service_id", null: false
    t.bigint "user_id", null: false
    t.integer "rating"
    t.text "comment"
    t.string "reference", null: false
    t.string "status", default: "published", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_service_reviews_on_reference", unique: true
    t.index ["service_id"], name: "index_service_reviews_on_service_id"
    t.index ["status"], name: "index_service_reviews_on_status"
    t.index ["user_id"], name: "index_service_reviews_on_user_id"
  end

  create_table "services", force: :cascade do |t|
    t.string "slug", null: false
    t.json "name_translations"
    t.json "description_translations"
    t.string "category"
    t.boolean "priority", default: false, null: false
    t.boolean "emergency", default: false, null: false
    t.string "status", default: "active", null: false
    t.string "address"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "contact_email"
    t.string "contact_phone"
    t.string "expected_return"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "maintenance_message_translations"
    t.index ["category"], name: "index_services_on_category"
    t.index ["emergency"], name: "index_services_on_emergency"
    t.index ["priority"], name: "index_services_on_priority"
    t.index ["slug"], name: "index_services_on_slug", unique: true
    t.index ["status"], name: "index_services_on_status"
  end

  create_table "transport_disruptions", force: :cascade do |t|
    t.bigint "transport_line_id", null: false
    t.json "message_translations"
    t.string "severity", default: "info", null: false
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transport_line_id"], name: "index_transport_disruptions_on_transport_line_id"
  end

  create_table "transport_lines", force: :cascade do |t|
    t.string "slug", null: false
    t.json "name_translations"
    t.json "description_translations"
    t.string "mode", default: "bus", null: false
    t.string "color"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_transport_lines_on_slug", unique: true
  end

  create_table "transport_schedules", force: :cascade do |t|
    t.bigint "transport_line_id", null: false
    t.integer "wday", null: false
    t.string "first_departure"
    t.string "last_departure"
    t.integer "frequency_minutes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transport_line_id"], name: "index_transport_schedules_on_transport_line_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "role", default: "citizen", null: false
    t.string "locale", default: "fr", null: false
    t.boolean "onboarding_completed", default: false, null: false
    t.boolean "high_contrast", default: false, null: false
    t.boolean "large_text", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "magic_link_nonce"
    t.datetime "magic_link_sent_at"
    t.string "otp_secret"
    t.boolean "otp_required", default: false, null: false
    t.datetime "otp_confirmed_at"
    t.boolean "reduced_data", default: false, null: false
    t.boolean "simple_mode", default: false, null: false
    t.string "login_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["login_id"], name: "index_users_on_login_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "agent_availabilities", "agents"
  add_foreign_key "agent_time_offs", "agents"
  add_foreign_key "appointments", "agents"
  add_foreign_key "appointments", "services"
  add_foreign_key "appointments", "users"
  add_foreign_key "consultation_responses", "consultations"
  add_foreign_key "consultation_responses", "users"
  add_foreign_key "consultations", "projects"
  add_foreign_key "demands", "agents", column: "assignee_id"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "idea_supports", "ideas"
  add_foreign_key "idea_supports", "users"
  add_foreign_key "ideas", "users"
  add_foreign_key "login_activities", "users"
  add_foreign_key "notifications", "users"
  add_foreign_key "partner_opening_hours", "partners"
  add_foreign_key "profiles", "users"
  add_foreign_key "request_events", "requests"
  add_foreign_key "request_supports", "requests"
  add_foreign_key "request_supports", "users"
  add_foreign_key "requests", "requests", column: "duplicate_of_id"
  add_foreign_key "requests", "services"
  add_foreign_key "requests", "users"
  add_foreign_key "service_reviews", "services"
  add_foreign_key "service_reviews", "users"
  add_foreign_key "transport_disruptions", "transport_lines"
  add_foreign_key "transport_schedules", "transport_lines"
end
