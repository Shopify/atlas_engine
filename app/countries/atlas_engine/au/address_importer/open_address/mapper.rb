# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Au
    module AddressImporter
      module OpenAddress
        class Mapper < AtlasEngine::AddressImporter::OpenAddress::DefaultMapper
          sig do
            params(feature: AtlasEngine::AddressImporter::OpenAddress::Feature).returns(T::Hash[Symbol, T.untyped])
          end
          def map(feature)
            region, city, street, number, unit, postcode = feature["properties"].values_at(
              "region",
              "city",
              "street",
              "number",
              "unit",
              "postcode",
            )
            {
              source_id: openaddress_source_id(feature),
              locale: @locale,
              country_code: "AU",
              province_code: province_from_code(region),
              # Omitted: region1..4
              city: [city.titleize],
              suburb: nil, # District field seems to always be empty and not useful
              zip: postcode,
              street: street.titleize,
              # NOTE: unit seems to be 'UNIT|SUITE|CARSPACE|SHOP|VILLA N'. Do we strip text before the number?
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
