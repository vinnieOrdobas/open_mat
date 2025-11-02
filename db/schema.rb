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

ActiveRecord::Schema[7.2].define(version: 2025_11_02_162833) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone_number"
    t.string "website"
    t.text "description"
    t.string "street_address", null: false
    t.string "city", null: false
    t.string "state_province"
    t.string "postal_code"
    t.string "country", null: false
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "payout_info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_academies_on_email", unique: true
    t.index ["user_id"], name: "index_academies_on_user_id"
  end

  create_table "academy_amenities", force: :cascade do |t|
    t.bigint "academy_id", null: false
    t.bigint "amenity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_academy_amenities_on_academy_id"
    t.index ["amenity_id"], name: "index_academy_amenities_on_amenity_id"
  end

  create_table "amenities", force: :cascade do |t|
    t.string "name", null: false
    t.string "category", null: false
    t.string "icon_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_amenities_on_name", unique: true
  end

  create_table "order_line_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "pass_id", null: false
    t.integer "quantity", default: 1, null: false
    t.integer "price_at_purchase_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status", default: "pending_approval", null: false
    t.index ["order_id"], name: "index_order_line_items_on_order_id"
    t.index ["pass_id"], name: "index_order_line_items_on_pass_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "status", default: "pending", null: false
    t.integer "total_price_cents", default: 0, null: false
    t.string "currency", default: "EUR", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "passes", force: :cascade do |t|
    t.bigint "academy_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "price_cents", default: 0, null: false
    t.string "currency", default: "EUR", null: false
    t.string "pass_type", null: false
    t.integer "class_credits"
    t.boolean "is_active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_passes_on_academy_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "status", default: "pending", null: false
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.string "processor", null: false
    t.string "processor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_payments_on_order_id"
  end

  create_table "student_passes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "pass_id", null: false
    t.bigint "order_line_item_id", null: false
    t.bigint "academy_id", null: false
    t.string "status", default: "active", null: false
    t.datetime "expires_at"
    t.integer "credits_remaining"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_student_passes_on_academy_id"
    t.index ["order_line_item_id"], name: "index_student_passes_on_order_line_item_id"
    t.index ["pass_id"], name: "index_student_passes_on_pass_id"
    t.index ["user_id"], name: "index_student_passes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "firstname", null: false
    t.string "lastname", null: false
    t.string "email", null: false
    t.string "username", null: false
    t.string "password_digest", null: false
    t.string "nationality"
    t.string "phone_number"
    t.date "date_of_birth"
    t.string "belt_rank"
    t.string "role", default: "student", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "academies", "users"
  add_foreign_key "academy_amenities", "academies"
  add_foreign_key "academy_amenities", "amenities"
  add_foreign_key "order_line_items", "orders"
  add_foreign_key "order_line_items", "passes"
  add_foreign_key "orders", "users"
  add_foreign_key "passes", "academies"
  add_foreign_key "payments", "orders"
  add_foreign_key "student_passes", "academies"
  add_foreign_key "student_passes", "order_line_items"
  add_foreign_key "student_passes", "passes"
  add_foreign_key "student_passes", "users"
end
