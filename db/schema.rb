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

ActiveRecord::Schema.define(version: 20161116171231) do

  create_table "decideds", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "room_id"
    t.integer  "suggest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "order"
    t.index ["room_id"], name: "index_decideds_on_room_id", using: :btree
    t.index ["suggest_id"], name: "index_decideds_on_suggest_id", using: :btree
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "message",    limit: 65535
    t.integer  "user_id"
    t.integer  "room_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["room_id"], name: "index_messages_on_room_id", using: :btree
    t.index ["user_id"], name: "index_messages_on_user_id", using: :btree
  end

  create_table "room_to_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "room_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id", "user_id"], name: "index_room_to_users_on_room_id_and_user_id", unique: true, using: :btree
    t.index ["room_id"], name: "index_room_to_users_on_room_id", using: :btree
    t.index ["user_id"], name: "index_room_to_users_on_user_id", using: :btree
  end

  create_table "rooms", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.boolean  "enable",                default: true, null: false
    t.string   "url",        limit: 12,                null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.index ["url"], name: "index_rooms_on_url", unique: true, using: :btree
  end

  create_table "suggests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "url"
    t.text     "description", limit: 65535
    t.integer  "room_id"
    t.integer  "user_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.text     "title",       limit: 65535
    t.text     "image",       limit: 65535
    t.boolean  "enable",                    default: true, null: false
    t.index ["room_id"], name: "index_suggests_on_room_id", using: :btree
    t.index ["user_id"], name: "index_suggests_on_user_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",            null: false
    t.string   "icon"
    t.string   "password_digest", null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["name"], name: "index_users_on_name", unique: true, using: :btree
  end

  create_table "vote_results", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "vote_id"
    t.integer  "user_id"
    t.integer  "suggest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["suggest_id"], name: "index_vote_results_on_suggest_id", using: :btree
    t.index ["user_id"], name: "index_vote_results_on_user_id", using: :btree
    t.index ["vote_id"], name: "index_vote_results_on_vote_id", using: :btree
  end

  create_table "vote_to_suggests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "vote_id"
    t.integer  "suggest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["suggest_id"], name: "index_vote_to_suggests_on_suggest_id", using: :btree
    t.index ["vote_id"], name: "index_vote_to_suggests_on_vote_id", using: :btree
  end

  create_table "votes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_foreign_key "decideds", "rooms"
  add_foreign_key "decideds", "suggests"
  add_foreign_key "messages", "rooms"
  add_foreign_key "messages", "users"
  add_foreign_key "suggests", "rooms"
  add_foreign_key "suggests", "users"
  add_foreign_key "vote_results", "suggests"
  add_foreign_key "vote_results", "users"
  add_foreign_key "vote_results", "votes"
  add_foreign_key "vote_to_suggests", "suggests"
  add_foreign_key "vote_to_suggests", "votes"
end
