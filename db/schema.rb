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

ActiveRecord::Schema.define(version: 2024_11_02_204400) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apostol_profiles", force: :cascade do |t|
    t.bigint "game_account_id", null: false
    t.integer "voice_count", default: 0, null: false
    t.integer "buffs_given", default: 0, null: false
    t.integer "chat_id", null: false
    t.integer "races", array: true
    t.datetime "last_buff_given_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_account_id"], name: "index_apostol_profiles_on_game_account_id"
  end

  create_table "buff_tasks", force: :cascade do |t|
    t.bigint "game_account_id", null: false
    t.bigint "apostol_profile_id", null: false
    t.integer "buff_type", default: 0, null: false
    t.integer "request_message_id", null: false
    t.boolean "resolved", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["apostol_profile_id"], name: "index_buff_tasks_on_apostol_profile_id"
    t.index ["game_account_id"], name: "index_buff_tasks_on_game_account_id"
  end

  create_table "game_accounts", force: :cascade do |t|
    t.integer "vk_id", null: false
    t.integer "buffs_received", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "apostol_profiles", "game_accounts"
  add_foreign_key "buff_tasks", "apostol_profiles"
  add_foreign_key "buff_tasks", "game_accounts"
end
