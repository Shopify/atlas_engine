# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Bm
    module AddressImporter
      module OpenAddress
        class Mapper < AtlasEngine::AddressImporter::OpenAddress::DefaultMapper
          sig do
            params(feature: AtlasEngine::AddressImporter::OpenAddress::Feature).returns(T::Hash[Symbol, T.untyped])
          end
          def map(feature)
            city, street, number, unit, postcode = feature["properties"].values_at(
              "district",
              "street",
              "number",
              "unit",
              "postcode",
            )
            result = {
              source_id: openaddress_source_id(feature),
              locale: @locale,
              country_code: "BM",
              province_code: nil,
              # Omitted: region1..4
              city: [city], # city names are already titleized
              suburb: nil,
              zip: normalize_zip(postcode),
              street: street.titleize,
              building_and_unit_ranges: housenumber_and_unit(number, unit),
              latitude: geometry(feature)&.at(1),
              longitude: geometry(feature)&.at(0),
            }
            result
          end
        end
      end
    end
  end
end
