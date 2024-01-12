# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Pt
    module AddressImporter
      module OpenAddress
        class Mapper < AtlasEngine::AddressImporter::OpenAddress::DefaultMapper
          sig do
            params(feature: AtlasEngine::AddressImporter::OpenAddress::Feature).returns(T::Hash[Symbol, T.untyped])
          end
          def map(feature)
            city, street, number, unit, postcode = feature["properties"].values_at(
              "city",
              "street",
              "number",
              "unit",
              "postcode",
            )
            {
              source_id: openaddress_source_id(feature),
              locale: @locale,
              country_code: "PT",
              province_code: province_code_from_zip(postcode),
              # Omitted: region1..4
              city: [city.titleize],
              suburb: nil,
              zip: postcode,
              street: street.titleize,
              building_and_unit_ranges: housenumber_and_unit(number, unit),
              latitude: geometry(feature)&.at(1),
              longitude: geometry(feature)&.at(0),
            }
          end
        end
      end
    end
  end
end
