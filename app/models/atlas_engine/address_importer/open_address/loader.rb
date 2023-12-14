# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class Loader
        extend T::Sig

        sig { params(addresses: T::Array[Hash]).void }
        def load(addresses)
          PostAddress.upsert_all( # rubocop:disable Rails/SkipsModelValidations
            addresses,
            on_duplicate: merge_building_ranges_clause,
          )
        end

        private

        def merge_building_ranges_clause
          Arel.sql("building_and_unit_ranges =
              JSON_MERGE(#{PostAddress.table_name}.building_and_unit_ranges, VALUES(building_and_unit_ranges))")
        end
      end
    end
  end
end
