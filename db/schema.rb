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

ActiveRecord::Schema.define(version: 2021_03_28_160537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "learning_stocks", force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.string "desired_weight"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "writer_id", null: false
    t.integer "level_of_competence", default: 0
    t.index ["writer_id"], name: "index_learning_stocks_on_writer_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.string "label"
    t.boolean "reached"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "writers", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_writers_on_email", unique: true
    t.index ["reset_password_token"], name: "index_writers_on_reset_password_token", unique: true
  end

  add_foreign_key "learning_stocks", "writers"
end
