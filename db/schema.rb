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

ActiveRecord::Schema.define(version: 20150130105841) do

  create_table "book_datas", force: true do |t|
    t.string   "isbn"
    t.string   "name"
    t.string   "edition"
    t.string   "author"
    t.string   "image_url"
    t.string   "url"
    t.string   "publisher"
    t.float    "original_price"
    t.integer  "user_id"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_datas", ["isbn"], name: "index_book_datas_on_isbn", unique: true

  create_table "books", force: true do |t|
    t.float    "price"
    t.integer  "book_data_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["book_data_id"], name: "index_books_on_book_data_id"

  create_table "courses", force: true do |t|
    t.integer  "year"
    t.integer  "term"
    t.string   "name"
    t.text     "description"
    t.integer  "credits"
    t.string   "url"
    t.string   "book_isbn"
    t.integer  "user_id"
    t.integer  "organization_id"
    t.integer  "lecturer_id"
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_identities", force: true do |t|
    t.integer  "user_id"
    t.string   "organization_code"
    t.string   "department_code"
    t.string   "uid"
    t.string   "email"
    t.string   "identity"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",               default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "sid"
    t.datetime "refreshed_at"
    t.string   "core_access_token"
    t.string   "core_refresh_token"
    t.string   "username"
    t.string   "name"
    t.string   "avatar_url"
    t.string   "cover_photo_url"
    t.string   "gender"
    t.string   "fbid"
    t.string   "uid"
    t.string   "identity"
    t.string   "organization"
    t.string   "department"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
