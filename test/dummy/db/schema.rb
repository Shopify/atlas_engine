# typed: false
# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 2024_01_02_213964) do
  create_table "atlas_engine_country_imports",
    charset: "utf8mb4",
    collation: "utf8mb4_unicode_ci",
    force: :cascade do |t|
    t.string("country_code", null: false)
    t.string("state", default: "pending")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
  end

  create_table "atlas_engine_events", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.bigint("country_import_id", null: false)
    t.text("message")
    t.json("additional_params")
    t.integer("category", default: 0)
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.index(["country_import_id"], name: "index_atlas_engine_events_on_country_import_id")
  end

  create_table "atlas_engine_post_addresses",
    charset: "utf8mb4",
    collation: "utf8mb4_unicode_ci",
    force: :cascade do |t|
    t.string("source_id")
    t.string("locale")
    t.string("country_code")
    t.string("province_code")
    t.string("region1")
    t.string("region2")
    t.string("region3")
    t.string("region4")
    t.string("city")
    t.string("suburb")
    t.string("zip")
    t.string("street")
    t.string("building_name")
    t.float("latitude")
    t.float("longitude")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.json("building_and_unit_ranges")
    t.index(["city"], name: "index_atlas_engine_post_addresses_on_city")
    t.index(["country_code"], name: "index_atlas_engine_post_addresses_on_country_code")
    t.index(
      ["province_code", "zip", "street", "city", "locale"],
      name: "index_atlas_engine_post_addresses_on_pc_zp_st_ct_lc",
      unique: true,
      length: { province_code: 10, zip: 10, street: 100, locale: 10 },
    )
    t.index(["province_code"], name: "index_atlas_engine_post_addresses_on_province_code")
    t.index(["source_id", "locale", "country_code"], name: "index_atlas_engine_post_addresses_on_srcid_loc_cc")
    t.index(["street"], name: "index_atlas_engine_post_addresses_on_street")
    t.index(["zip"], name: "index_atlas_engine_post_addresses_on_zip")
  end

  create_table "maintenance_tasks_runs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
    t.string("task_name", null: false)
    t.datetime("started_at", precision: nil)
    t.datetime("ended_at", precision: nil)
    t.float("time_running", default: 0.0, null: false)
    t.bigint("tick_count", default: 0, null: false)
    t.bigint("tick_total")
    t.string("job_id")
    t.string("cursor")
    t.string("status", default: "enqueued", null: false)
    t.string("error_class")
    t.string("error_message")
    t.text("backtrace")
    t.datetime("created_at", null: false)
    t.datetime("updated_at", null: false)
    t.text("arguments")
    t.integer("lock_version", default: 0, null: false)
    t.text("metadata")
    t.index(["task_name", "status", "created_at"], name: "index_maintenance_tasks_runs", order: { created_at: :desc })
  end
end
