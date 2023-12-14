# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module OpenAddress
      class DefaultMapper
        extend T::Sig
        include FeatureHelper
        sig { params(country_code: String, locale: T.nilable(String)).void }
        def initialize(country_code:, locale: nil)
          @country_code = country_code
          @locale = locale
        end

        sig { params(feature: Feature).returns(T::Hash[Symbol, T.untyped]) }
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
            country_code: @country_code,
            province_code: nil,
            region1: region,
            # Don't titleize. The sources have proper capitalization, and it's a problem for cities like
            # 's-Graveland, which would get titleized to "'S Graveland" which is wrong.
            city: [city],
            suburb: nil,
            zip: normalize_zip(postcode),
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
