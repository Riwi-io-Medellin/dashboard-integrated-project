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

ActiveRecord::Schema[8.0].define(version: 2026_02_27_133410) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "coders", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "student_id"
    t.string "national_id"
    t.string "email"
    t.string "phone"
    t.string "gender"
    t.bigint "group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "github_user"
    t.string "discord_user"
    t.index ["email"], name: "index_coders_on_email"
    t.index ["group_id"], name: "index_coders_on_group_id"
    t.index ["student_id"], name: "index_coders_on_student_id", unique: true
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jornada"
    t.integer "capacity", default: 30
    t.index ["name"], name: "index_groups_on_name", unique: true
  end

  create_table "team_members", force: :cascade do |t|
    t.bigint "team_id", null: false
    t.bigint "coder_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coder_id"], name: "index_team_members_on_coder_id"
    t.index ["coder_id"], name: "index_team_members_on_coder_unique", unique: true
    t.index ["team_id", "coder_id"], name: "index_team_members_on_team_id_and_coder_id", unique: true
    t.index ["team_id"], name: "index_team_members_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name", null: false
    t.string "project_category", null: false
    t.bigint "group_id", null: false
    t.string "token", null: false
    t.datetime "registered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "needs_openai_api", default: false, null: false
    t.bigint "created_by_user_id"
    t.text "description"
    t.string "github_repo_url"
    t.index ["created_by_user_id"], name: "index_teams_on_created_by_user_id"
    t.index ["group_id"], name: "index_teams_on_group_id"
    t.index ["token"], name: "index_teams_on_token", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role", default: "coder", null: false
    t.bigint "coder_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_number"
    t.index ["coder_id"], name: "index_users_on_coder_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "coders", "groups"
  add_foreign_key "team_members", "coders"
  add_foreign_key "team_members", "teams"
  add_foreign_key "teams", "groups"
  add_foreign_key "teams", "users", column: "created_by_user_id"
  add_foreign_key "users", "coders"
end
