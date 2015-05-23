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

ActiveRecord::Schema.define(version: 20150523191350) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bills", force: :cascade do |t|
    t.string   "uuid",                                         null: false
    t.integer  "user_id",                                      null: false
    t.string   "type",                                         null: false
    t.integer  "price",                                        null: false
    t.integer  "amount",                                       null: false
    t.integer  "invoice_id"
    t.string   "invoice_type",                                 null: false
    t.text     "invoice_data"
    t.text     "data"
    t.string   "state",                                        null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payment_code"
    t.datetime "paid_at"
    t.integer  "used_credits"
    t.datetime "deadline",     default: '2015-05-23 19:23:14', null: false
  end

  add_index "bills", ["deadline"], name: "index_bills_on_deadline", using: :btree
  add_index "bills", ["deleted_at"], name: "index_bills_on_deleted_at", using: :btree
  add_index "bills", ["invoice_id"], name: "index_bills_on_invoice_id", unique: true, using: :btree
  add_index "bills", ["invoice_type"], name: "index_bills_on_invoice_type", using: :btree
  add_index "bills", ["state"], name: "index_bills_on_state", using: :btree
  add_index "bills", ["type"], name: "index_bills_on_type", using: :btree
  add_index "bills", ["user_id"], name: "index_bills_on_user_id", using: :btree
  add_index "bills", ["uuid"], name: "index_bills_on_uuid", unique: true, using: :btree

  create_table "book_datas", force: :cascade do |t|
    t.string   "isbn"
    t.string   "name",                null: false
    t.string   "edition"
    t.string   "author"
    t.string   "external_image_url"
    t.string   "url"
    t.string   "publisher"
    t.string   "original_url"
    t.integer  "original_price"
    t.string   "known_provider"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "temporary_book_name"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "book_datas", ["isbn"], name: "index_book_datas_on_isbn", unique: true, using: :btree

  create_table "books", force: :cascade do |t|
    t.string   "provider"
    t.integer  "price",             null: false
    t.string   "isbn"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "organization_code"
  end

  add_index "books", ["deleted_at"], name: "index_books_on_deleted_at", using: :btree
  add_index "books", ["isbn"], name: "index_books_on_isbn", using: :btree
  add_index "books", ["organization_code"], name: "index_books_on_organization_code", using: :btree

  create_table "courses", force: :cascade do |t|
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
    t.string   "updated_through"
  end

  add_index "courses", ["deleted_at"], name: "index_courses_on_deleted_at", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "code",                                   null: false
    t.integer  "leader_id",                              null: false
    t.integer  "course_id"
    t.integer  "book_id",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "shipped_at"
    t.datetime "received_at"
    t.string   "pickup_point"
    t.string   "pickup_date"
    t.string   "pickup_time"
    t.text     "data"
    t.string   "organization_code"
    t.string   "recipient_mobile"
    t.string   "recipient_name"
    t.string   "state",             default: "grouping", null: false
    t.boolean  "public",            default: false,      null: false
    t.datetime "deadline"
    t.datetime "pickup_datetime"
  end

  add_index "groups", ["code"], name: "index_groups_on_code", unique: true, using: :btree
  add_index "groups", ["deadline"], name: "index_groups_on_deadline", using: :btree
  add_index "groups", ["leader_id"], name: "index_groups_on_leader_id", using: :btree
  add_index "groups", ["organization_code"], name: "index_groups_on_organization_code", using: :btree
  add_index "groups", ["public"], name: "index_groups_on_public", using: :btree
  add_index "groups", ["received_at"], name: "index_groups_on_received_at", using: :btree
  add_index "groups", ["shipped_at"], name: "index_groups_on_shipped_at", using: :btree
  add_index "groups", ["state"], name: "index_groups_on_state", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.string   "group_code", null: false
    t.integer  "book_id",    null: false
    t.integer  "price"
    t.string   "state",      null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bill_uuid"
  end

  add_index "orders", ["bill_uuid"], name: "index_orders_on_bill_uuid", using: :btree
  add_index "orders", ["book_id"], name: "index_orders_on_book_id", using: :btree
  add_index "orders", ["deleted_at"], name: "index_orders_on_deleted_at", using: :btree
  add_index "orders", ["group_code"], name: "index_orders_on_group_code", using: :btree
  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree
  add_index "orders", ["user_id"], name: "index_orders_on_user_id", using: :btree

  create_table "pickup_selections_dates", force: :cascade do |t|
    t.string   "organization_code"
    t.string   "batch"
    t.string   "selection"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pickup_selections_dates", ["batch"], name: "index_pickup_selections_dates_on_batch", using: :btree
  add_index "pickup_selections_dates", ["organization_code"], name: "index_pickup_selections_dates_on_organization_code", using: :btree

  create_table "pickup_selections_points", force: :cascade do |t|
    t.string   "organization_code"
    t.string   "batch"
    t.string   "selection"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pickup_selections_points", ["batch"], name: "index_pickup_selections_points_on_batch", using: :btree
  add_index "pickup_selections_points", ["organization_code"], name: "index_pickup_selections_points_on_organization_code", using: :btree

  create_table "pickup_selections_times", force: :cascade do |t|
    t.string   "organization_code"
    t.string   "batch"
    t.string   "selection"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pickup_selections_times", ["batch"], name: "index_pickup_selections_times_on_batch", using: :btree
  add_index "pickup_selections_times", ["organization_code"], name: "index_pickup_selections_times_on_organization_code", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "user_cart_items", force: :cascade do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quantity",   default: 1, null: false
    t.string   "item_type"
    t.string   "item_code"
    t.string   "item_name"
    t.string   "item_link"
    t.integer  "item_price"
  end

  add_index "user_cart_items", ["user_id"], name: "index_user_cart_items_on_user_id", using: :btree

  create_table "user_identities", force: :cascade do |t|
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

  add_index "user_identities", ["sid"], name: "index_user_identities_on_sid", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                            default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0,  null: false
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
    t.integer  "cart_items_count",                 default: 0
    t.integer  "credits",                          default: 0,  null: false
    t.string   "uuid",                                          null: false
    t.string   "invoice_subsume_token"
    t.datetime "invoice_subsume_token_created_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["uuid"], name: "index_users_on_uuid", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
