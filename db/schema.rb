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

ActiveRecord::Schema.define(version: 20180411152550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "addressable_type", null: false
    t.bigint "addressable_id", null: false
    t.string "street_1", null: false
    t.string "street_2"
    t.string "city", null: false
    t.string "state"
    t.string "postal_code", null: false
    t.string "country"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.string "token"
    t.bigint "user_id"
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.inet "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_auth_tokens_on_token"
    t.index ["user_id"], name: "index_auth_tokens_on_user_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "official_name", null: false
    t.string "alpha_2_code", limit: 2, null: false
    t.string "alpha_3_code", limit: 3, null: false
  end

  create_table "data_plans", force: :cascade do |t|
    t.bigint "user_id"
    t.string "units", default: "bytes"
    t.bigint "total_amount", default: 1000000000
    t.bigint "total_amount_used", default: 0
    t.bigint "warning_amount", default: 50000000
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_data_plans_on_user_id"
  end

  create_table "data_usage_records", force: :cascade do |t|
    t.bigint "user_id"
    t.string "units", default: "bytes"
    t.datetime "start"
    t.datetime "end"
    t.bigint "total_usage"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_data_usage_records_on_user_id"
  end

  create_table "itineraries", force: :cascade do |t|
    t.bigint "trip_id"
    t.bigint "country_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_itineraries_on_country_id"
    t.index ["trip_id"], name: "index_itineraries_on_trip_id"
  end

  create_table "shipments", force: :cascade do |t|
    t.bigint "sim_id"
    t.string "tracking_number"
    t.string "carrier"
    t.integer "status"
    t.string "tracking_link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sim_id"], name: "index_shipments_on_sim_id"
  end

  create_table "sims", force: :cascade do |t|
    t.string "sid"
    t.string "uuid"
    t.string "rate_plan_sid"
    t.string "name"
    t.string "iccid"
    t.string "e_id"
    t.integer "status", default: 0
    t.string "phone_number"
    t.string "country_code"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "activation_code"
    t.boolean "test_sim", default: false
    t.index ["user_id"], name: "index_sims_on_user_id"
  end

  create_table "stripe_customers", force: :cascade do |t|
    t.string "stripe_id"
    t.string "default_source"
    t.string "billable_type"
    t.bigint "billable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billable_type", "billable_id"], name: "index_stripe_customers_on_billable_type_and_billable_id"
  end

  create_table "trips", force: :cascade do |t|
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_trips_on_user_id"
  end

  create_table "users", force: :cascade do |t|
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
    t.string "first_name"
    t.string "last_name"
    t.boolean "admin", default: false
    t.boolean "beta_user", default: false
    t.string "add_payment_token"
    t.datetime "add_payment_token_expires"
    t.datetime "last_data_warning_message_sent"
    t.datetime "last_data_exceeded_message_sent"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
