# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20130904070010) do

  create_table "bombs", force: true do |t|
    t.integer  "x"
    t.integer  "y"
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "player_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "grid_elems", force: true do |t|
    t.string   "block_type"
    t.integer  "x"
    t.integer  "y"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "location"
  end

  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "players", force: true do |t|
    t.integer  "x"
    t.integer  "y"
    t.integer  "user_id"
    t.integer  "game_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profiles", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "head_color",      default: "#FA0909"
    t.string   "limbs_color",     default: "#000000"
    t.string   "eyes_color",      default: "#1AFF00"
    t.string   "bomb_color",      default: "#000000"
    t.string   "explosion_color", default: "#FA0909"
    t.string   "body_color",      default: "#0004FF"
  end

  create_table "socials", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sn_type"
    t.integer  "user_id"
    t.string   "social_id"
    t.string   "avatar_url",  default: "default_avatar.svg"
    t.string   "name"
    t.string   "social_link"
  end

  add_index "socials", ["user_id"], name: "index_socials_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "avatar_url",          default: "default_avatar.svg"
    t.string   "email",               default: "",                   null: false
    t.integer  "sign_in_count",       default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "remember_created_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
