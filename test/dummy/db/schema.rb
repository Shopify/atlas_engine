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

ActiveRecord::Schema[7.0].define(version: 2023_09_19_173037) do
  create_table "maintenance_tasks_runs", force: :cascade do |t|
    t.string "task_name", null: false
    t.datetime "started_at", precision: nil
    t.datetime "ended_at", precision: nil
    t.float "time_running", default: 0.0, null: false
    t.integer "tick_count", default: 0, null: false
    t.integer "tick_total"
    t.string "job_id"
    t.bigint "cursor"
    t.string "status", default: "enqueued", null: false
    t.string "error_class"
    t.string "error_message"
    t.text "backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "arguments"
    t.integer "lock_version", default: 0, null: false
    t.index ["task_name", "created_at"], name: "index_maintenance_tasks_runs_on_task_name_and_created_at"
  end

  create_table "post_addresses", force: :cascade do |t|
    t.string "locale"
    t.string "country_code"
    t.string "province_code"
    t.string "region1"
    t.string "region2"
    t.string "region3"
    t.string "region4"
    t.string "city"
    t.string "suburb"
    t.string "zip"
    t.string "street"
    t.string "building_name"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city"], name: "index_post_addresses_on_city"
    t.index ["country_code"], name: "index_post_addresses_on_country_code"
    t.index ["province_code"], name: "index_post_addresses_on_province_code"
    t.index ["street"], name: "index_post_addresses_on_street"
    t.index ["zip"], name: "index_post_addresses_on_zip"
  end

end
