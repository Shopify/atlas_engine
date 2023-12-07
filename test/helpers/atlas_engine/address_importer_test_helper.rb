# typed: false
# frozen_string_literal: true

require "test_helper"

module AtlasEngine
  module AddressImporterTestHelper
    def rollback_sqlite_db_transactions(db, &block)
      db.transaction(rollback: :always, auto_savepoint: true, &block)
    end

    def truncate_sqlite_db_tables(db, tables = nil)
      tables ||= [:address, :city, :shared_postal_box, :neighborhood]

      tables.each do |table|
        db[table].truncate
      end
    end

    # NOTE: See `address_importer/br/addresses.yml` for an example of the expected format
    def seed_sqlite_db(db, country_code = "")
      create_schema(db, country_code)
      addresses = YAML.safe_load_file(file_fixture("address_importer/#{country_code}/addresses.yml"))
      seeds = addresses.values.pluck("seeds")

      seeds.each do |seed|
        seed.deep_symbolize_keys.each do |table, item|
          # rubocop:disable Rails/SkipsModelValidations
          db[table].insert(item)
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end

    def create_schema(db, country_code)
      schema = Rails.root.join("lib/tasks/#{country_code}/schema.sql").read
      db.run(schema)
    end

    def generate_csv(data)
      CSV.new(StringIO.new(data), headers: true, col_sep: ";")
    end

    def build_post_address_struct(city: "", province_code: "", zip: "", country_code: "")
      AddressImporter::Validation::Wrapper::AddressStruct.new(
        city: city,
        province_code: province_code,
        zip: zip,
        country_code: country_code,
      )
    end
  end
end
