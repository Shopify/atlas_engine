# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Gb
    module ValidationTranscriber
      class ParsedAddress
        extend T::Sig

        sig { returns(T.nilable(String)) }
        attr_accessor :building_num # may be alphanumeric, e.g. "2A"

        sig { returns(T.nilable(String)) }
        attr_accessor :dependent_street # what Royal Mail calls a dependent thoroughfare

        sig { returns(T.nilable(String)) }
        attr_accessor :street # what Royal Mail calls a thoroughfare

        sig { returns(T.nilable(String)) }
        attr_accessor :unit_type

        sig { returns(T.nilable(String)) }
        attr_accessor :unit_num

        sig { returns(T.nilable(String)) }
        attr_accessor :double_dependent_locality

        sig { returns(T.nilable(String)) }
        attr_accessor :dependent_locality

        sig { returns(T.nilable(String)) }
        attr_accessor :post_town # the :city field may contain "{post_town}, {county}"

        sig { returns(T.nilable(String)) }
        attr_accessor :county # deprecated in 1996, but still permitted

        sig { returns(T.nilable(String)) }
        attr_accessor :province_code

        sig { returns(T.any(Symbol, String)) }
        attr_accessor :country_code

        sig { returns(T.nilable(String)) }
        attr_accessor :zip

        sig do
          params(
            country_code: T.any(Symbol, String),
            building_num: T.nilable(String),
            dependent_street: T.nilable(String),
            street: T.nilable(String),
            unit_type: T.nilable(String),
            unit_num: T.nilable(String),
            double_dependent_locality: T.nilable(String),
            dependent_locality: T.nilable(String),
            post_town: T.nilable(String),
            county: T.nilable(String),
            province_code: T.nilable(String),
            zip: T.nilable(String),
          ).void
        end
        def initialize(
          country_code:,
          building_num: nil,
          dependent_street: nil,
          street: nil,
          unit_type: nil,
          unit_num: nil,
          double_dependent_locality: nil,
          dependent_locality: nil,
          post_town: nil,
          county: nil,
          province_code: nil,
          zip: nil
        )
          @building_num = building_num
          @dependent_street = dependent_street
          @street = street
          @unit_type = unit_type
          @unit_num = unit_num
          @double_dependent_locality = double_dependent_locality
          @dependent_locality = dependent_locality
          @post_town = post_town
          @county = county
          @province_code = province_code
          @country_code = country_code
          @zip = zip
        end

        sig { params(other: ParsedAddress).returns(T::Boolean) }
        def ==(other)
          @country_code.presence == other.country_code.presence &&
            @building_num.presence == other.building_num.presence &&
            @dependent_street.presence == other.dependent_street.presence &&
            @street.presence == other.street.presence &&
            @unit_type.presence == other.unit_type.presence &&
            @unit_num.presence == other.unit_num.presence &&
            @double_dependent_locality.presence == other.double_dependent_locality.presence &&
            @dependent_locality.presence == other.dependent_locality.presence &&
            @post_town.presence == other.post_town.presence &&
            @county.presence == other.county.presence &&
            @zip.presence == other.zip.presence &&

            # If no province is given in GB, we'll infer it with a postcode lookup
            (
              @province_code.presence == other.province_code.presence ||
                inferred_province_code == other.send(:inferred_province_code)
            )
        end

        private

        sig { returns(T.nilable(String)) }
        def inferred_province_code
          @province_code.presence || Worldwide.region(code: @country_code)&.zone(zip: @zip)&.legacy_code
        end
      end
    end
  end
end
