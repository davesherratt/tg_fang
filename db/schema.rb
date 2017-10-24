# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171022175200) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "alliance", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "age"
    t.string "name", limit: 255
    t.string "alias", limit: 255
    t.integer "size"
    t.integer "members"
    t.bigint "score"
    t.integer "points"
    t.bigint "score_total"
    t.bigint "value_total"
    t.integer "xp"
    t.float "ratio"
    t.integer "size_rank"
    t.integer "members_rank"
    t.integer "score_rank"
    t.integer "points_rank"
    t.integer "size_avg"
    t.integer "score_avg"
    t.integer "points_avg"
    t.integer "size_avg_rank"
    t.integer "score_avg_rank"
    t.integer "points_avg_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "points_growth"
    t.integer "member_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "points_growth_pc"
    t.integer "size_avg_growth"
    t.integer "score_avg_growth"
    t.integer "points_avg_growth"
    t.float "size_avg_growth_pc"
    t.float "score_avg_growth_pc"
    t.float "points_avg_growth_pc"
    t.integer "size_rank_change"
    t.integer "members_rank_change"
    t.integer "score_rank_change"
    t.integer "points_rank_change"
    t.integer "size_avg_rank_change"
    t.integer "score_avg_rank_change"
    t.integer "points_avg_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.integer "sdiff"
    t.integer "pdiff"
    t.integer "rdiff"
    t.integer "mdiff"
    t.integer "srankdiff"
    t.integer "prankdiff"
    t.integer "rrankdiff"
    t.integer "mrankdiff"
    t.integer "savgdiff"
    t.integer "pavgdiff"
    t.integer "ravgdiff"
    t.integer "savgrankdiff"
    t.integer "pavgrankdiff"
    t.integer "ravgrankdiff"
    t.integer "idle"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "members_highest_rank"
    t.integer "members_highest_rank_tick"
    t.integer "members_lowest_rank"
    t.integer "members_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "points_highest_rank"
    t.integer "points_highest_rank_tick"
    t.integer "points_lowest_rank"
    t.integer "points_lowest_rank_tick"
    t.integer "size_avg_highest_rank"
    t.integer "size_avg_highest_rank_tick"
    t.integer "size_avg_lowest_rank"
    t.integer "size_avg_lowest_rank_tick"
    t.integer "score_avg_highest_rank"
    t.integer "score_avg_highest_rank_tick"
    t.integer "score_avg_lowest_rank"
    t.integer "score_avg_lowest_rank_tick"
    t.integer "points_avg_highest_rank"
    t.integer "points_avg_highest_rank_tick"
    t.integer "points_avg_lowest_rank"
    t.integer "points_avg_lowest_rank_tick"
    t.index ["name"], name: "ix_alliance_name"
  end

  create_table "alliance_history", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "tick", null: false
    t.integer "hour"
    t.datetime "timestamp"
    t.integer "id", null: false
    t.boolean "active"
    t.integer "age"
    t.string "name", limit: 255
    t.string "alias", limit: 255
    t.integer "size"
    t.integer "members"
    t.bigint "score"
    t.integer "points"
    t.bigint "score_total"
    t.bigint "value_total"
    t.integer "xp"
    t.float "ratio"
    t.integer "size_rank"
    t.integer "members_rank"
    t.integer "score_rank"
    t.integer "points_rank"
    t.integer "size_avg"
    t.integer "score_avg"
    t.integer "points_avg"
    t.integer "size_avg_rank"
    t.integer "score_avg_rank"
    t.integer "points_avg_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "points_growth"
    t.integer "member_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "points_growth_pc"
    t.integer "size_avg_growth"
    t.integer "score_avg_growth"
    t.integer "points_avg_growth"
    t.float "size_avg_growth_pc"
    t.float "score_avg_growth_pc"
    t.float "points_avg_growth_pc"
    t.integer "size_rank_change"
    t.integer "members_rank_change"
    t.integer "score_rank_change"
    t.integer "points_rank_change"
    t.integer "size_avg_rank_change"
    t.integer "score_avg_rank_change"
    t.integer "points_avg_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.integer "sdiff"
    t.integer "pdiff"
    t.integer "rdiff"
    t.integer "mdiff"
    t.integer "srankdiff"
    t.integer "prankdiff"
    t.integer "rrankdiff"
    t.integer "mrankdiff"
    t.integer "savgdiff"
    t.integer "pavgdiff"
    t.integer "ravgdiff"
    t.integer "savgrankdiff"
    t.integer "pavgrankdiff"
    t.integer "ravgrankdiff"
    t.integer "idle"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "members_highest_rank"
    t.integer "members_highest_rank_tick"
    t.integer "members_lowest_rank"
    t.integer "members_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "points_highest_rank"
    t.integer "points_highest_rank_tick"
    t.integer "points_lowest_rank"
    t.integer "points_lowest_rank_tick"
    t.integer "size_avg_highest_rank"
    t.integer "size_avg_highest_rank_tick"
    t.integer "size_avg_lowest_rank"
    t.integer "size_avg_lowest_rank_tick"
    t.integer "score_avg_highest_rank"
    t.integer "score_avg_highest_rank_tick"
    t.integer "score_avg_lowest_rank"
    t.integer "score_avg_lowest_rank_tick"
    t.integer "points_avg_highest_rank"
    t.integer "points_avg_highest_rank_tick"
    t.integer "points_avg_lowest_rank"
    t.integer "points_avg_lowest_rank_tick"
    t.index ["hour"], name: "ix_alliance_history_hour"
  end

  create_table "alliance_temp", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.integer "id"
    t.integer "size"
    t.integer "members"
    t.bigint "score"
    t.integer "points"
    t.integer "score_rank"
    t.bigint "score_total"
    t.bigint "value_total"
    t.integer "size_avg"
    t.integer "score_avg"
    t.integer "points_avg"
  end

  create_table "apenis", primary_key: "rank", id: :serial, force: :cascade do |t|
    t.integer "alliance_id"
    t.integer "penis"
    t.index ["alliance_id"], name: "ix_apenis_alliance_id"
  end

  create_table "cluster", primary_key: "x", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "age"
    t.integer "size"
    t.integer "score"
    t.integer "value"
    t.integer "xp"
    t.integer "members"
    t.float "ratio"
    t.integer "size_rank"
    t.integer "score_rank"
    t.integer "value_rank"
    t.integer "xp_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "value_growth"
    t.integer "xp_growth"
    t.integer "member_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "value_growth_pc"
    t.float "xp_growth_pc"
    t.integer "size_rank_change"
    t.integer "score_rank_change"
    t.integer "value_rank_change"
    t.integer "xp_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.float "roidxp"
    t.integer "vdiff"
    t.integer "sdiff"
    t.integer "xdiff"
    t.integer "rdiff"
    t.integer "mdiff"
    t.integer "vrankdiff"
    t.integer "srankdiff"
    t.integer "xrankdiff"
    t.integer "rrankdiff"
    t.integer "idle"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "value_highest_rank"
    t.integer "value_highest_rank_tick"
    t.integer "value_lowest_rank"
    t.integer "value_lowest_rank_tick"
    t.integer "xp_highest_rank"
    t.integer "xp_highest_rank_tick"
    t.integer "xp_lowest_rank"
    t.integer "xp_lowest_rank_tick"
  end

  create_table "cluster_history", primary_key: ["tick", "x"], force: :cascade do |t|
    t.integer "tick", null: false
    t.integer "hour"
    t.datetime "timestamp"
    t.integer "x", null: false
    t.boolean "active"
    t.integer "age"
    t.integer "size"
    t.integer "score"
    t.integer "value"
    t.integer "xp"
    t.integer "members"
    t.float "ratio"
    t.integer "size_rank"
    t.integer "score_rank"
    t.integer "value_rank"
    t.integer "xp_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "value_growth"
    t.integer "xp_growth"
    t.integer "member_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "value_growth_pc"
    t.float "xp_growth_pc"
    t.integer "size_rank_change"
    t.integer "score_rank_change"
    t.integer "value_rank_change"
    t.integer "xp_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.float "roidxp"
    t.integer "vdiff"
    t.integer "sdiff"
    t.integer "xdiff"
    t.integer "rdiff"
    t.integer "mdiff"
    t.integer "vrankdiff"
    t.integer "srankdiff"
    t.integer "xrankdiff"
    t.integer "rrankdiff"
    t.integer "idle"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "value_highest_rank"
    t.integer "value_highest_rank_tick"
    t.integer "value_lowest_rank"
    t.integer "value_lowest_rank_tick"
    t.integer "xp_highest_rank"
    t.integer "xp_highest_rank_tick"
    t.integer "xp_lowest_rank"
    t.integer "xp_lowest_rank_tick"
    t.index ["hour"], name: "ix_cluster_history_hour"
    t.index ["x", "tick"], name: "cluster_history_x_tick_key", unique: true
  end

  create_table "constructions", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.integer "cu"
    t.integer "metal"
    t.integer "crystal"
    t.integer "eonium"
    t.string "description", limit: 255
  end

  create_table "feed", id: :serial, force: :cascade do |t|
    t.integer "tick"
    t.string "category", limit: 255
    t.integer "alliance1_id"
    t.integer "alliance2_id"
    t.integer "alliance3_id"
    t.string "planet_id", limit: 8
    t.integer "galaxy_id"
    t.string "text", limit: 255
    t.index ["alliance1_id"], name: "ix_feed_alliance1_id"
    t.index ["alliance2_id"], name: "ix_feed_alliance2_id"
    t.index ["alliance3_id"], name: "ix_feed_alliance3_id"
    t.index ["category"], name: "ix_feed_category"
    t.index ["galaxy_id"], name: "ix_feed_galaxy_id"
    t.index ["planet_id"], name: "ix_feed_planet_id"
  end

  create_table "galaxy", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "age"
    t.integer "x"
    t.integer "y"
    t.string "name", limit: 255
    t.integer "size"
    t.integer "score"
    t.integer "real_score"
    t.integer "value"
    t.integer "xp"
    t.integer "members"
    t.float "ratio"
    t.integer "size_rank"
    t.integer "score_rank"
    t.integer "real_score_rank"
    t.integer "value_rank"
    t.integer "xp_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "real_score_growth"
    t.integer "value_growth"
    t.integer "xp_growth"
    t.integer "member_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "real_score_growth_pc"
    t.float "value_growth_pc"
    t.float "xp_growth_pc"
    t.integer "size_rank_change"
    t.integer "score_rank_change"
    t.integer "real_score_rank_change"
    t.integer "value_rank_change"
    t.integer "xp_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.float "roidxp"
    t.integer "vdiff"
    t.integer "sdiff"
    t.integer "rsdiff"
    t.integer "xdiff"
    t.integer "rdiff"
    t.integer "mdiff"
    t.integer "vrankdiff"
    t.integer "srankdiff"
    t.integer "rsrankdiff"
    t.integer "xrankdiff"
    t.integer "rrankdiff"
    t.integer "idle"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "real_score_highest_rank"
    t.integer "real_score_highest_rank_tick"
    t.integer "real_score_lowest_rank"
    t.integer "real_score_lowest_rank_tick"
    t.integer "value_highest_rank"
    t.integer "value_highest_rank_tick"
    t.integer "value_lowest_rank"
    t.integer "value_lowest_rank_tick"
    t.integer "xp_highest_rank"
    t.integer "xp_highest_rank_tick"
    t.integer "xp_lowest_rank"
    t.integer "xp_lowest_rank_tick"
    t.boolean "private"
    t.index ["x", "y"], name: "galaxy_x_y", unique: true
  end

  create_table "galaxy_history", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "tick", null: false
    t.integer "hour"
    t.datetime "timestamp"
    t.integer "id", null: false
    t.boolean "active"
    t.integer "age"
    t.integer "x"
    t.integer "y"
    t.string "name", limit: 255
    t.integer "size"
    t.integer "score"
    t.integer "real_score"
    t.integer "value"
    t.integer "xp"
    t.integer "members"
    t.float "ratio"
    t.integer "size_rank"
    t.integer "score_rank"
    t.integer "real_score_rank"
    t.integer "value_rank"
    t.integer "xp_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "real_score_growth"
    t.integer "value_growth"
    t.integer "xp_growth"
    t.integer "member_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "real_score_growth_pc"
    t.float "value_growth_pc"
    t.float "xp_growth_pc"
    t.integer "size_rank_change"
    t.integer "score_rank_change"
    t.integer "real_score_rank_change"
    t.integer "value_rank_change"
    t.integer "xp_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.float "roidxp"
    t.integer "vdiff"
    t.integer "sdiff"
    t.integer "rsdiff"
    t.integer "xdiff"
    t.integer "rdiff"
    t.integer "mdiff"
    t.integer "vrankdiff"
    t.integer "srankdiff"
    t.integer "rsrankdiff"
    t.integer "xrankdiff"
    t.integer "rrankdiff"
    t.integer "idle"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "real_score_highest_rank"
    t.integer "real_score_highest_rank_tick"
    t.integer "real_score_lowest_rank"
    t.integer "real_score_lowest_rank_tick"
    t.integer "value_highest_rank"
    t.integer "value_highest_rank_tick"
    t.integer "value_lowest_rank"
    t.integer "value_lowest_rank_tick"
    t.integer "xp_highest_rank"
    t.integer "xp_highest_rank_tick"
    t.integer "xp_lowest_rank"
    t.integer "xp_lowest_rank_tick"
    t.boolean "private"
    t.index ["hour"], name: "ix_galaxy_history_hour"
    t.index ["x", "y", "tick"], name: "galaxy_history_x_y_tick_key", unique: true
  end

  create_table "galaxy_temp", primary_key: ["x", "y"], force: :cascade do |t|
    t.integer "id"
    t.integer "x", null: false
    t.integer "y", null: false
    t.string "name", limit: 255
    t.integer "size"
    t.integer "score"
    t.integer "value"
    t.integer "xp"
  end

  create_table "galpenis", primary_key: "rank", id: :serial, force: :cascade do |t|
    t.integer "galaxy_id"
    t.integer "penis"
    t.index ["galaxy_id"], name: "ix_galpenis_galaxy_id"
  end

  create_table "game_setup", primary_key: "key", id: :string, limit: 255, force: :cascade do |t|
    t.string "value", limit: 255
  end

  create_table "govs", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.string "description", limit: 1023
    t.string "alert", limit: 255
    t.string "construction", limit: 255
    t.string "mining", limit: 255
    t.string "production_cost", limit: 255
    t.string "production_time", limit: 255
    t.string "research", limit: 255
    t.float "amod"
    t.float "cmod"
    t.float "mmod"
    t.float "pcmod"
    t.float "ptmod"
    t.float "rmod"
  end

  create_table "heresy_arthur_log", id: :serial, force: :cascade do |t|
    t.string "page", limit: 255
    t.string "full_request", limit: 255
    t.string "username", limit: 255
    t.string "session", limit: 255
    t.string "planet_id", limit: 8
    t.string "hostname", limit: 255
    t.datetime "request_time"
  end

  create_table "heresy_attack", id: :serial, force: :cascade do |t|
    t.integer "landtick"
    t.text "comment"
    t.integer "waves"
  end

  create_table "heresy_attack_target", id: :serial, force: :cascade do |t|
    t.integer "attack_id"
    t.string "planet_id", limit: 8
  end

  create_table "heresy_channels", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "userlevel"
    t.integer "maxlevel"
    t.index ["name"], name: "heresy_channels_name_key", unique: true
  end

  create_table "heresy_command_log", id: :serial, force: :cascade do |t|
    t.string "command_prefix", limit: 255
    t.string "command", limit: 255
    t.string "subcommand", limit: 255
    t.string "command_parameters", limit: 500
    t.string "nick", limit: 255
    t.string "username", limit: 255
    t.string "hostname", limit: 255
    t.string "target", limit: 255
    t.datetime "command_time"
  end

  create_table "heresy_cookie_log", id: :serial, force: :cascade do |t|
    t.datetime "log_time"
    t.integer "year"
    t.integer "week"
    t.integer "howmany"
    t.integer "giver_id"
    t.integer "receiver_id"
  end

  create_table "heresy_covop", id: :serial, force: :cascade do |t|
    t.integer "scan_id"
    t.string "covopper_id", limit: 8
    t.string "target_id", limit: 8
  end

  create_table "heresy_devscan", id: :serial, force: :cascade do |t|
    t.integer "scan_id"
    t.integer "light_factory"
    t.integer "medium_factory"
    t.integer "heavy_factory"
    t.integer "wave_amplifier"
    t.integer "wave_distorter"
    t.integer "metal_refinery"
    t.integer "crystal_refinery"
    t.integer "eonium_refinery"
    t.integer "research_lab"
    t.integer "finance_centre"
    t.integer "military_centre"
    t.integer "security_centre"
    t.integer "structure_defence"
    t.integer "travel"
    t.integer "infrastructure"
    t.integer "hulls"
    t.integer "waves"
    t.integer "core"
    t.integer "covert_op"
    t.integer "mining"
    t.integer "pop"
  end

  create_table "heresy_epenis", primary_key: "rank", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "penis"
    t.index ["user_id"], name: "ix_heresy_epenis_user_id"
  end

  create_table "heresy_fleet_log", id: :serial, force: :cascade do |t|
    t.integer "taker_id"
    t.integer "user_id"
    t.integer "ship_id"
    t.integer "ship_count"
    t.integer "tick"
  end

  create_table "heresy_fleetscan", id: :serial, force: :cascade do |t|
    t.integer "scan_id"
    t.string "owner_id", limit: 8
    t.string "target_id", limit: 8
    t.integer "fleet_size"
    t.string "fleet_name", limit: 255
    t.integer "launch_tick"
    t.integer "landing_tick"
    t.string "mission", limit: 255
    t.boolean "in_cluster"
    t.boolean "in_galaxy"
    t.index ["owner_id", "target_id", "fleet_size", "fleet_name", "landing_tick", "mission"], name: "heresy_fleetscan_owner_id_target_id_fleet_size_fleet_name_l_key", unique: true
  end

  create_table "heresy_intel", primary_key: "planet_id", id: :string, limit: 8, force: :cascade do |t|
    t.integer "alliance_id"
    t.string "nick", limit: 255
    t.string "fakenick", limit: 255
    t.boolean "defwhore"
    t.boolean "covop"
    t.integer "amps"
    t.integer "dists"
    t.string "bg", limit: 255
    t.string "gov", limit: 255
    t.boolean "relay"
    t.string "reportchan", limit: 255
    t.string "comment", limit: 255
    t.index ["alliance_id"], name: "ix_heresy_intel_alliance_id"
  end

  create_table "heresy_invite_proposal", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "proposer_id"
    t.string "person", limit: 255
    t.datetime "created"
    t.datetime "closed"
    t.string "vote_result", limit: 255
    t.text "comment_text"
  end

  create_table "heresy_kick_proposal", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "proposer_id"
    t.integer "person_id"
    t.datetime "created"
    t.datetime "closed"
    t.string "vote_result", limit: 255
    t.text "comment_text"
  end

  create_table "heresy_notification", id: false, force: :cascade do |t|
    t.uuid "id", default: -> { "uuid_generate_v4()" }, null: false
    t.integer "user_id"
    t.string "message"
    t.string "subject"
    t.boolean "sent", default: false
    t.string "type_"
    t.string "x"
    t.string "y"
    t.string "z"
    t.string "lt"
    t.string "ship_count"
    t.string "fleet_name"
  end

  create_table "heresy_phonefriends", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "friend_id"
  end

  create_table "heresy_planetscan", id: :serial, force: :cascade do |t|
    t.integer "scan_id"
    t.integer "roid_metal"
    t.integer "roid_crystal"
    t.integer "roid_eonium"
    t.integer "res_metal"
    t.integer "res_crystal"
    t.integer "res_eonium"
    t.string "factory_usage_light", limit: 255
    t.string "factory_usage_medium", limit: 255
    t.string "factory_usage_heavy", limit: 255
    t.integer "prod_res"
    t.integer "sold_res"
    t.integer "agents"
    t.integer "guards"
  end

  create_table "heresy_prop_vote", id: :serial, force: :cascade do |t|
    t.string "vote", limit: 255
    t.integer "carebears"
    t.integer "prop_id"
    t.integer "voter_id"
  end

  create_table "heresy_quotes", id: :serial, force: :cascade do |t|
    t.string "text", limit: 255
  end

# Could not dump table "heresy_request" because of following StandardError
#   Unknown type 'scantype' for column 'scantype'

# Could not dump table "heresy_scan" because of following StandardError
#   Unknown type 'scantype' for column 'scantype'

  create_table "heresy_session", primary_key: "key", id: :string, limit: 255, force: :cascade do |t|
    t.integer "user_id"
    t.datetime "expire"
  end

  create_table "heresy_slogans", id: :serial, force: :cascade do |t|
    t.string "text", limit: 255
  end

  create_table "heresy_sms_log", id: :serial, force: :cascade do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.string "phone", limit: 255
    t.string "sms_text", limit: 255
    t.string "mode", limit: 255
  end

  create_table "heresy_suggestion_proposal", id: :serial, force: :cascade do |t|
    t.boolean "active"
    t.integer "proposer_id"
    t.datetime "created"
    t.datetime "closed"
    t.string "vote_result", limit: 255
    t.text "comment_text"
  end

  create_table "heresy_target", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "planet_id", limit: 8
    t.integer "tick"
    t.index ["planet_id", "tick"], name: "heresy_target_planet_id_tick_key", unique: true
    t.index ["planet_id"], name: "ix_heresy_target_planet_id"
    t.index ["user_id"], name: "ix_heresy_target_user_id"
  end

  create_table "heresy_tell", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "sender_id"
    t.boolean "read"
    t.string "message", limit: 255
  end

  create_table "heresy_unitscan", id: :serial, force: :cascade do |t|
    t.integer "scan_id"
    t.integer "ship_id"
    t.integer "amount"
  end

  create_table "heresy_user_fleet", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "ship_id"
    t.integer "ship_count"
  end

# Could not dump table "heresy_users" because of following StandardError
#   Unknown type 'smsmode' for column '_smsmode'

  create_table "planet", id: :string, limit: 8, force: :cascade do |t|
    t.boolean "active"
    t.integer "age"
    t.integer "x"
    t.integer "y"
    t.integer "z"
    t.string "planetname", limit: 255
    t.string "rulername", limit: 255
    t.string "race", limit: 255
    t.integer "size"
    t.integer "score"
    t.integer "value"
    t.integer "xp"
    t.string "special", limit: 255
    t.float "ratio"
    t.integer "size_rank"
    t.integer "score_rank"
    t.integer "value_rank"
    t.integer "xp_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "value_growth"
    t.integer "xp_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "value_growth_pc"
    t.float "xp_growth_pc"
    t.integer "size_rank_change"
    t.integer "score_rank_change"
    t.integer "value_rank_change"
    t.integer "xp_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.float "roidxp"
    t.integer "vdiff"
    t.integer "sdiff"
    t.integer "xdiff"
    t.integer "rdiff"
    t.integer "vrankdiff"
    t.integer "srankdiff"
    t.integer "xrankdiff"
    t.integer "rrankdiff"
    t.integer "idle"
    t.integer "cluster_size_rank"
    t.integer "cluster_score_rank"
    t.integer "cluster_value_rank"
    t.integer "cluster_xp_rank"
    t.integer "cluster_size_rank_change"
    t.integer "cluster_score_rank_change"
    t.integer "cluster_value_rank_change"
    t.integer "cluster_xp_rank_change"
    t.integer "cluster_totalroundroids_rank"
    t.integer "cluster_totallostroids_rank"
    t.integer "cluster_totalroundroids_rank_change"
    t.integer "cluster_totallostroids_rank_change"
    t.integer "galaxy_size_rank"
    t.integer "galaxy_score_rank"
    t.integer "galaxy_value_rank"
    t.integer "galaxy_xp_rank"
    t.integer "galaxy_size_rank_change"
    t.integer "galaxy_score_rank_change"
    t.integer "galaxy_value_rank_change"
    t.integer "galaxy_xp_rank_change"
    t.integer "galaxy_totalroundroids_rank"
    t.integer "galaxy_totallostroids_rank"
    t.integer "galaxy_totalroundroids_rank_change"
    t.integer "galaxy_totallostroids_rank_change"
    t.integer "race_size_rank"
    t.integer "race_score_rank"
    t.integer "race_value_rank"
    t.integer "race_xp_rank"
    t.integer "race_size_rank_change"
    t.integer "race_score_rank_change"
    t.integer "race_value_rank_change"
    t.integer "race_xp_rank_change"
    t.integer "race_totalroundroids_rank"
    t.integer "race_totallostroids_rank"
    t.integer "race_totalroundroids_rank_change"
    t.integer "race_totallostroids_rank_change"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "value_highest_rank"
    t.integer "value_highest_rank_tick"
    t.integer "value_lowest_rank"
    t.integer "value_lowest_rank_tick"
    t.integer "xp_highest_rank"
    t.integer "xp_highest_rank_tick"
    t.integer "xp_lowest_rank"
    t.integer "xp_lowest_rank_tick"
    t.index ["x", "y", "z"], name: "planet_x_y_z"
  end

  create_table "planet_exiles", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "hour"
    t.integer "tick", null: false
    t.string "id", limit: 8, null: false
    t.integer "oldx"
    t.integer "oldy"
    t.integer "oldz"
    t.integer "newx"
    t.integer "newy"
    t.integer "newz"
    t.index ["hour"], name: "ix_planet_exiles_hour"
  end

  create_table "planet_history", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "tick", null: false
    t.integer "hour"
    t.datetime "timestamp"
    t.string "id", limit: 8, null: false
    t.boolean "active"
    t.integer "age"
    t.integer "x"
    t.integer "y"
    t.integer "z"
    t.string "planetname", limit: 255
    t.string "rulername", limit: 255
    t.string "race", limit: 255
    t.integer "size"
    t.integer "score"
    t.integer "value"
    t.integer "xp"
    t.string "special", limit: 255
    t.float "ratio"
    t.integer "size_rank"
    t.integer "score_rank"
    t.integer "value_rank"
    t.integer "xp_rank"
    t.integer "size_growth"
    t.integer "score_growth"
    t.integer "value_growth"
    t.integer "xp_growth"
    t.float "size_growth_pc"
    t.float "score_growth_pc"
    t.float "value_growth_pc"
    t.float "xp_growth_pc"
    t.integer "size_rank_change"
    t.integer "score_rank_change"
    t.integer "value_rank_change"
    t.integer "xp_rank_change"
    t.integer "totalroundroids"
    t.integer "totallostroids"
    t.integer "totalroundroids_rank"
    t.integer "totallostroids_rank"
    t.integer "totalroundroids_rank_change"
    t.integer "totallostroids_rank_change"
    t.integer "totalroundroids_growth"
    t.integer "totallostroids_growth"
    t.integer "totalroundroids_growth_pc"
    t.integer "totallostroids_growth_pc"
    t.integer "ticksroiding"
    t.integer "ticksroided"
    t.integer "tickroids"
    t.float "avroids"
    t.float "roidxp"
    t.integer "vdiff"
    t.integer "sdiff"
    t.integer "xdiff"
    t.integer "rdiff"
    t.integer "vrankdiff"
    t.integer "srankdiff"
    t.integer "xrankdiff"
    t.integer "rrankdiff"
    t.integer "idle"
    t.integer "cluster_size_rank"
    t.integer "cluster_score_rank"
    t.integer "cluster_value_rank"
    t.integer "cluster_xp_rank"
    t.integer "cluster_size_rank_change"
    t.integer "cluster_score_rank_change"
    t.integer "cluster_value_rank_change"
    t.integer "cluster_xp_rank_change"
    t.integer "cluster_totalroundroids_rank"
    t.integer "cluster_totallostroids_rank"
    t.integer "cluster_totalroundroids_rank_change"
    t.integer "cluster_totallostroids_rank_change"
    t.integer "galaxy_size_rank"
    t.integer "galaxy_score_rank"
    t.integer "galaxy_value_rank"
    t.integer "galaxy_xp_rank"
    t.integer "galaxy_size_rank_change"
    t.integer "galaxy_score_rank_change"
    t.integer "galaxy_value_rank_change"
    t.integer "galaxy_xp_rank_change"
    t.integer "galaxy_totalroundroids_rank"
    t.integer "galaxy_totallostroids_rank"
    t.integer "galaxy_totalroundroids_rank_change"
    t.integer "galaxy_totallostroids_rank_change"
    t.integer "race_size_rank"
    t.integer "race_score_rank"
    t.integer "race_value_rank"
    t.integer "race_xp_rank"
    t.integer "race_size_rank_change"
    t.integer "race_score_rank_change"
    t.integer "race_value_rank_change"
    t.integer "race_xp_rank_change"
    t.integer "race_totalroundroids_rank"
    t.integer "race_totallostroids_rank"
    t.integer "race_totalroundroids_rank_change"
    t.integer "race_totallostroids_rank_change"
    t.integer "size_highest_rank"
    t.integer "size_highest_rank_tick"
    t.integer "size_lowest_rank"
    t.integer "size_lowest_rank_tick"
    t.integer "score_highest_rank"
    t.integer "score_highest_rank_tick"
    t.integer "score_lowest_rank"
    t.integer "score_lowest_rank_tick"
    t.integer "value_highest_rank"
    t.integer "value_highest_rank_tick"
    t.integer "value_lowest_rank"
    t.integer "value_lowest_rank_tick"
    t.integer "xp_highest_rank"
    t.integer "xp_highest_rank_tick"
    t.integer "xp_lowest_rank"
    t.integer "xp_lowest_rank_tick"
    t.index ["hour"], name: "ix_planet_history_hour"
  end

  create_table "planet_idles", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "hour"
    t.integer "tick", null: false
    t.string "id", limit: 8, null: false
    t.integer "idle"
    t.index ["hour"], name: "ix_planet_idles_hour"
  end

  create_table "planet_landed_on", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "hour"
    t.integer "tick", null: false
    t.string "id", limit: 8, null: false
    t.integer "rdiff"
    t.index ["hour"], name: "ix_planet_landed_on_hour"
  end

  create_table "planet_landings", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "hour"
    t.integer "tick", null: false
    t.string "id", limit: 8, null: false
    t.integer "rdiff"
    t.index ["hour"], name: "ix_planet_landings_hour"
  end

  create_table "planet_temp", primary_key: ["x", "y", "z"], force: :cascade do |t|
    t.string "id", limit: 8
    t.integer "x", null: false
    t.integer "y", null: false
    t.integer "z", null: false
    t.string "planetname", limit: 255
    t.string "rulername", limit: 255
    t.string "race", limit: 255
    t.integer "size"
    t.integer "score"
    t.integer "value"
    t.integer "xp"
    t.string "special", limit: 255
  end

  create_table "planet_value_drops", primary_key: ["tick", "id"], force: :cascade do |t|
    t.integer "hour"
    t.integer "tick", null: false
    t.string "id", limit: 8, null: false
    t.integer "vdiff"
    t.index ["hour"], name: "ix_planet_value_drops_hour"
  end

  create_table "races", primary_key: "short_name", id: :string, limit: 255, force: :cascade do |t|
    t.string "full_name", limit: 255
    t.string "description", limit: 1023
    t.integer "base_cu"
    t.integer "base_rp"
    t.integer "trade_tax"
    t.integer "max_stealth"
    t.integer "stealth_growth"
    t.integer "production"
    t.integer "salvage"
  end

  create_table "research", primary_key: "name", id: :string, limit: 255, force: :cascade do |t|
    t.integer "branch"
    t.integer "level"
    t.integer "rp"
    t.string "description", limit: 255
  end

  create_table "ships", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "class_", limit: 255
    t.string "t1", limit: 255
    t.string "t2", limit: 255
    t.string "t3", limit: 255
    t.string "type_", limit: 255
    t.integer "init"
    t.integer "guns"
    t.integer "armor"
    t.integer "damage"
    t.integer "empres"
    t.integer "metal"
    t.integer "crystal"
    t.integer "eonium"
    t.integer "total_cost"
    t.integer "baseeta"
    t.string "race", limit: 255
  end

  create_table "updates", id: :integer, default: nil, force: :cascade do |t|
    t.string "etag", limit: 255
    t.string "modified", limit: 255
    t.integer "galaxies"
    t.integer "planets"
    t.integer "alliances"
    t.datetime "timestamp"
    t.integer "unixtime"
    t.integer "clusters"
    t.integer "c200"
    t.integer "ter"
    t.integer "cat"
    t.integer "xan"
    t.integer "zik"
    t.integer "etd"
  end

  create_table "users", force: :cascade do |t|
    t.integer "uid"
  end

  create_table "war", primary_key: ["start_tick", "alliance1_id", "alliance2_id"], force: :cascade do |t|
    t.integer "start_tick", null: false
    t.integer "end_tick"
    t.integer "alliance1_id", null: false
    t.integer "alliance2_id", null: false
    t.index ["alliance1_id"], name: "ix_war_alliance1_id"
    t.index ["alliance2_id"], name: "ix_war_alliance2_id"
  end

  add_foreign_key "alliance_history", "alliance", column: "id", name: "alliance_history_id_fkey"
  add_foreign_key "alliance_history", "updates", column: "tick", name: "alliance_history_tick_fkey", on_delete: :cascade
  add_foreign_key "apenis", "alliance", name: "apenis_alliance_id_fkey", on_delete: :cascade
  add_foreign_key "cluster_history", "cluster", column: "x", primary_key: "x", name: "cluster_history_x_fkey"
  add_foreign_key "cluster_history", "updates", column: "tick", name: "cluster_history_tick_fkey", on_delete: :cascade
  add_foreign_key "feed", "alliance", column: "alliance1_id", name: "feed_alliance1_id_fkey", on_delete: :nullify
  add_foreign_key "feed", "alliance", column: "alliance2_id", name: "feed_alliance2_id_fkey", on_delete: :nullify
  add_foreign_key "feed", "alliance", column: "alliance3_id", name: "feed_alliance3_id_fkey", on_delete: :nullify
  add_foreign_key "feed", "galaxy", name: "feed_galaxy_id_fkey", on_delete: :nullify
  add_foreign_key "feed", "planet", name: "feed_planet_id_fkey", on_delete: :nullify
  add_foreign_key "galaxy", "cluster", column: "x", primary_key: "x", name: "galaxy_x_fkey"
  add_foreign_key "galaxy_history", "cluster_history", column: "x", primary_key: "x", name: "galaxy_history_x_fkey"
  add_foreign_key "galaxy_history", "galaxy", column: "id", name: "galaxy_history_id_fkey"
  add_foreign_key "galaxy_history", "updates", column: "tick", name: "galaxy_history_tick_fkey", on_delete: :cascade
  add_foreign_key "galpenis", "galaxy", name: "galpenis_galaxy_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_attack_target", "heresy_attack", column: "attack_id", name: "heresy_attack_target_attack_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_attack_target", "planet", name: "heresy_attack_target_planet_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_cookie_log", "heresy_users", column: "giver_id", name: "heresy_cookie_log_giver_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_cookie_log", "heresy_users", column: "receiver_id", name: "heresy_cookie_log_receiver_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_covop", "heresy_scan", column: "scan_id", name: "heresy_covop_scan_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_covop", "planet", column: "covopper_id", name: "heresy_covop_covopper_id_fkey", on_delete: :nullify
  add_foreign_key "heresy_covop", "planet", column: "target_id", name: "heresy_covop_target_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_devscan", "heresy_scan", column: "scan_id", name: "heresy_devscan_scan_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_epenis", "heresy_users", column: "user_id", name: "heresy_epenis_user_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_fleet_log", "heresy_users", column: "taker_id", name: "heresy_fleet_log_taker_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_fleet_log", "heresy_users", column: "user_id", name: "heresy_fleet_log_user_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_fleet_log", "ships", name: "heresy_fleet_log_ship_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_fleetscan", "heresy_scan", column: "scan_id", name: "heresy_fleetscan_scan_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_fleetscan", "planet", column: "owner_id", name: "heresy_fleetscan_owner_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_fleetscan", "planet", column: "target_id", name: "heresy_fleetscan_target_id_fkey", on_delete: :nullify
  add_foreign_key "heresy_intel", "alliance", name: "heresy_intel_alliance_id_fkey", on_delete: :nullify
  add_foreign_key "heresy_intel", "planet", name: "heresy_intel_planet_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_invite_proposal", "heresy_users", column: "proposer_id", name: "heresy_invite_proposal_proposer_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_kick_proposal", "heresy_users", column: "person_id", name: "heresy_kick_proposal_person_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_kick_proposal", "heresy_users", column: "proposer_id", name: "heresy_kick_proposal_proposer_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_phonefriends", "heresy_users", column: "friend_id", name: "heresy_phonefriends_friend_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_phonefriends", "heresy_users", column: "user_id", name: "heresy_phonefriends_user_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_planetscan", "heresy_scan", column: "scan_id", name: "heresy_planetscan_scan_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_prop_vote", "heresy_users", column: "voter_id", name: "heresy_prop_vote_voter_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_request", "heresy_scan", column: "scan_id", name: "heresy_request_scan_id_fkey", on_delete: :nullify
  add_foreign_key "heresy_request", "heresy_users", column: "requester_id", name: "heresy_request_requester_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_request", "planet", name: "heresy_request_planet_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_scan", "heresy_users", column: "scanner_id", name: "heresy_scan_scanner_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_scan", "planet", name: "heresy_scan_planet_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_session", "heresy_users", column: "user_id", name: "heresy_session_user_id_fkey", on_delete: :nullify
  add_foreign_key "heresy_sms_log", "heresy_users", column: "receiver_id", name: "heresy_sms_log_receiver_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_sms_log", "heresy_users", column: "sender_id", name: "heresy_sms_log_sender_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_suggestion_proposal", "heresy_users", column: "proposer_id", name: "heresy_suggestion_proposal_proposer_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_target", "heresy_users", column: "user_id", name: "heresy_target_user_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_target", "planet", name: "heresy_target_planet_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_tell", "heresy_users", column: "sender_id", name: "heresy_tell_sender_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_tell", "heresy_users", column: "user_id", name: "heresy_tell_user_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_unitscan", "heresy_scan", column: "scan_id", name: "heresy_unitscan_scan_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_unitscan", "ships", name: "heresy_unitscan_ship_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_user_fleet", "heresy_users", column: "user_id", name: "heresy_user_fleet_user_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_user_fleet", "ships", name: "heresy_user_fleet_ship_id_fkey", on_delete: :cascade
  add_foreign_key "heresy_users", "planet", name: "heresy_users_planet_id_fkey", on_delete: :nullify
  add_foreign_key "planet", "galaxy", column: "x", primary_key: "x", name: "planet_x_fkey"
  add_foreign_key "planet_exiles", "galaxy", column: "newx", primary_key: "x", name: "planet_exiles_newx_fkey"
  add_foreign_key "planet_exiles", "galaxy", column: "oldx", primary_key: "x", name: "planet_exiles_oldx_fkey"
  add_foreign_key "planet_exiles", "planet", column: "id", name: "planet_exiles_id_fkey"
  add_foreign_key "planet_exiles", "updates", column: "tick", name: "planet_exiles_tick_fkey", on_delete: :cascade
  add_foreign_key "planet_history", "galaxy_history", column: "x", primary_key: "x", name: "planet_history_x_fkey"
  add_foreign_key "planet_history", "planet", column: "id", name: "planet_history_id_fkey"
  add_foreign_key "planet_history", "updates", column: "tick", name: "planet_history_tick_fkey", on_delete: :cascade
  add_foreign_key "planet_idles", "planet", column: "id", name: "planet_idles_id_fkey"
  add_foreign_key "planet_idles", "updates", column: "tick", name: "planet_idles_tick_fkey", on_delete: :cascade
  add_foreign_key "planet_landed_on", "planet", column: "id", name: "planet_landed_on_id_fkey"
  add_foreign_key "planet_landed_on", "updates", column: "tick", name: "planet_landed_on_tick_fkey", on_delete: :cascade
  add_foreign_key "planet_landings", "planet", column: "id", name: "planet_landings_id_fkey"
  add_foreign_key "planet_landings", "updates", column: "tick", name: "planet_landings_tick_fkey", on_delete: :cascade
  add_foreign_key "planet_value_drops", "planet", column: "id", name: "planet_value_drops_id_fkey"
  add_foreign_key "planet_value_drops", "updates", column: "tick", name: "planet_value_drops_tick_fkey", on_delete: :cascade
  add_foreign_key "war", "alliance", column: "alliance1_id", name: "war_alliance1_id_fkey", on_delete: :nullify
  add_foreign_key "war", "alliance", column: "alliance2_id", name: "war_alliance2_id_fkey", on_delete: :nullify
end
