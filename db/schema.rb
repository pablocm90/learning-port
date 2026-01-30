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

ActiveRecord::Schema[8.0].define(version: 2026_01_30_132326) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "learning_items", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.string "category"
    t.integer "status"
    t.text "description"
    t.date "started_at"
    t.jsonb "resources", default: []
    t.text "notes"
    t.jsonb "projects", default: []
    t.integer "position", default: 0
    t.string "source", default: "admin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "podcast_episodes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "episode_number"
    t.date "published_at"
    t.text "embed_code"
    t.jsonb "external_links", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["episode_number"], name: "index_podcast_episodes_on_episode_number", unique: true
  end

  create_table "writers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.text "bio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_writers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_writers_on_reset_password_token", unique: true
  end
end
