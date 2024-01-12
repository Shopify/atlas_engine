# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Kr
    module AddressImporter
      module OpenAddress
        class Mapper < AtlasEngine::AddressImporter::OpenAddress::DefaultMapper
          sig do
            params(feature: AtlasEngine::AddressImporter::OpenAddress::Feature).returns(T::Hash[Symbol, T.untyped])
          end
          def map(feature)
            region, district, city, street, number, unit, postcode = feature["properties"].values_at(
              "region",
              "district",
              "city",
              "street",
              "number",
              "unit",
              "postcode",
            )
            {
              source_id: openaddress_source_id(feature),
              locale: @locale,
              country_code: "KR",
              province_code: province_code_from_name(region),
              region1: region,
              city: [city],
              suburb: district,
              zip: postcode,
              street: street,
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
