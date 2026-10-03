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

ActiveRecord::Schema[8.1].define(version: 2026_10_03_170000) do
  create_table "agents", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  create_table "demand_syncs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  create_table "demands", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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
    t.index ["request_code"], name: "index_demands_on_request_code", unique: true
    t.index ["triage_status"], name: "index_demands_on_triage_status"
    t.index ["wave_number"], name: "index_demands_on_wave_number"
  end

  create_table "profiles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "versions", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", limit: 191, null: false
    t.string "event", null: false
    t.text "object", size: :long
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "demands", "agents", column: "assignee_id"
  add_foreign_key "profiles", "users"
end
