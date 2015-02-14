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

ActiveRecord::Schema.define(version: 20150214022341) do

  create_table "book_datas", force: true do |t|
    t.string   "isbn"
    t.string   "name",           null: false
    t.string   "edition"
    t.string   "author"
    t.string   "image_url"
    t.string   "url"
    t.string   "publisher"
    t.string   "original_url"
    t.float    "original_price"
    t.string   "known_provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "book_datas", ["isbn"], name: "index_book_datas_on_isbn", unique: true

  create_table "books", force: true do |t|
    t.string   "provider"
    t.float    "price",          null: false
    t.string   "book_data_isbn"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "books", ["book_data_isbn"], name: "index_books_on_book_data_isbn", unique: true

  create_table "courses", force: true do |t|
    t.string   "organization_code",                 null: false
    t.string   "department_code"
    t.string   "lecturer_name",                     null: false
    t.integer  "year",                              null: false
    t.integer  "term",                              null: false
    t.string   "name",                              null: false
    t.string   "code"
    t.string   "url"
    t.boolean  "required",          default: false, null: false
    t.string   "book_isbn"
    t.string   "unknown_book_name"
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "version_count",     default: 0,     null: false
  end

  add_index "courses", ["deleted_at"], name: "index_courses_on_deleted_at"

  create_table "user_cart_items", force: true do |t|
    t.integer  "user_id"
    t.integer  "book_id"
    t.integer  "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_cart_items", ["book_id"], name: "index_user_cart_items_on_book_id"
  add_index "user_cart_items", ["course_id"], name: "index_user_cart_items_on_course_id"
  add_index "user_cart_items", ["user_id"], name: "index_user_cart_items_on_user_id"

  create_table "user_identities", force: true do |t|
    t.integer  "user_id",           null: false
    t.string   "organization_code", null: false
    t.string   "department_code"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "identity",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sid"
    t.string   "organization_name"
    t.string   "department_name"
  end

  add_index "user_identities", ["sid"], name: "index_user_identities_on_sid", unique: true

  create_table "users", force: true do |t|
    t.string   "email",               default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "sid"
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
    t.string   "organization_code"
    t.string   "department_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cart_items_count",    default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
