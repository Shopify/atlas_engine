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
  create_table "atlas_engine_test_one_post_addresses", charset: "utf8mb3", force: :cascade do |t|
    t.string "source_id"
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
    t.index ["city"], name: "index_atlas_engine_test_one_post_addresses_on_city"
    t.index ["country_code"], name: "index_atlas_engine_test_one_post_addresses_on_country_code"
    t.index ["province_code"], name: "index_atlas_engine_test_one_post_addresses_on_province_code"
    t.index ["street"], name: "index_atlas_engine_test_one_post_addresses_on_street"
    t.index ["zip"], name: "index_atlas_engine_test_one_post_addresses_on_zip"
  end

end
