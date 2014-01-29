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

ActiveRecord::Schema.define(version: 20140129054254) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "alarms", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.datetime "wake_at"
    t.datetime "pushed_at"
    t.datetime "texted_at"
    t.datetime "called_at"
    t.integer  "pushes"
    t.integer  "texts"
    t.integer  "calls"
    t.integer  "user_id"
    t.integer  "uptime_id"
  end

  create_table "sessions", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer  "user_id"
  end

  create_table "uptime_logs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.datetime "pushed_at"
    t.datetime "texted_at"
    t.datetime "called_at"
    t.integer  "offset"
    t.integer  "pushes"
    t.integer  "texts"
    t.integer  "calls"
    t.integer  "user_id"
    t.integer  "uptime_id"
  end

  create_table "uptimes", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "status"
    t.datetime "wake_at"
  end

  add_index "uptimes", ["user_id"], name: "index_uptimes_on_user_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "phone"
    t.string   "token"
    t.string   "locale"
    t.string   "version"
    t.string   "code"
    t.string   "vcode"
    t.integer  "timezone"
    t.datetime "verified_at"
    t.string   "udid"
    t.string   "bundle"
    t.string   "status"
    t.string   "apn"
    t.datetime "apn_at"
  end

  add_index "users", ["phone"], name: "index_users_on_phone", unique: true, using: :btree

end
