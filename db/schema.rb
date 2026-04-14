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

ActiveRecord::Schema[7.2].define(version: 2026_04_14_005128) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_categories_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "content_units", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_content_units_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_content_units_on_user_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "category_id"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["user_id", "name"], name: "index_items_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "pack_units", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_pack_units_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_pack_units_on_user_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.string "brand"
    t.decimal "content_quantity", precision: 8, scale: 2, null: false
    t.integer "pack_quantity", default: 1, null: false
    t.integer "price", null: false
    t.decimal "unit_price", precision: 8, scale: 2, null: false
    t.integer "tax_rate", default: 0, null: false
    t.bigint "user_id", null: false
    t.bigint "store_id"
    t.bigint "item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "purchased_on", default: -> { "CURRENT_DATE" }, null: false
    t.bigint "content_unit_id", null: false
    t.bigint "pack_unit_id"
    t.index ["content_unit_id"], name: "index_purchases_on_content_unit_id"
    t.index ["item_id"], name: "index_purchases_on_item_id"
    t.index ["pack_unit_id"], name: "index_purchases_on_pack_unit_id"
    t.index ["store_id"], name: "index_purchases_on_store_id"
    t.index ["user_id"], name: "index_purchases_on_user_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_stores_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_stores_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email"
    t.string "encrypted_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "categories", "users"
  add_foreign_key "content_units", "users"
  add_foreign_key "items", "categories", on_delete: :nullify
  add_foreign_key "items", "users"
  add_foreign_key "pack_units", "users"
  add_foreign_key "purchases", "content_units"
  add_foreign_key "purchases", "items"
  add_foreign_key "purchases", "pack_units", on_delete: :nullify
  add_foreign_key "purchases", "stores", on_delete: :nullify
  add_foreign_key "purchases", "users"
  add_foreign_key "stores", "users"
end
