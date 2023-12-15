# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Gb
    module ValidationTranscriber
      class FullAddressParser
        extend T::Sig
        include AtlasEngine::ValidationTranscriber::Formatter

        sig { params(address: AtlasEngine::AddressValidation::AbstractAddress).void }
        def initialize(address:)
          @address = address
        end

        # Note that parse() returns an array of possible interpretations, because it's sometimes
        # impossible to be sure how to classify some parts of an address without more context.
        #
        # Consider the following two examples.
        #
        # Example 1:
        #   2 Elm Avenue         [building_num] [dependent_street]
        #   Runcorn Road         [street]
        #   BIRMINGHAM           [post_town]
        #   B12 8QX              [zip]
        #
        # Example 2:
        #   1 Liechrhyd Terrace  [building_num] [street]
        #   Builth Road          [dependent_locality]
        #   BUILTH WELLS         [post_town]
        #   LD2 3PY              [zip]
        #
        # In the first example, "Runcorn Road" is thoroughfare, and "Elm Avenue" is a dependent thoroughfare.
        # In the second example, "Builth Road" is a dependent locality (hamlet), not a thoroughfare.
        #
        sig { returns(T::Array[ValidationTranscriber::ParsedAddress]) }
        def parse
          city = @address.city
          if city.present?
            city_parts = city.split(",").map(&:strip)
            post_town = city_parts.first
            if city_parts.count > 1
              county = city_parts[1..-1]&.join(", ")
            end
          end

          parsed_address = ValidationTranscriber::ParsedAddress.new(
            zip: @address.zip,
            province_code: @address.province_code,
            country_code: @address.country_code || "GB",
            post_town: post_town,
            county: county,
          )

          # Split address1 and address2 on both commas and newlines
          components = split_into_components(@address)

          pivot = components.count > 3 ? 3 : components.length
          pivot.downto(1).map do |pivot_value|
            street_components, locality_components = components.partition.with_index do |_, index|
              index <= components.count - pivot_value
            end
            hypothesize(
              street_components: street_components,
              locality_components: locality_components,
              parsed_fields: parsed_address,
            )
          end.flatten
        end

        private

        sig do
          params(
            conjecture: T::Hash[Symbol, String],
            double_dependent_locality: T.nilable(String),
            dependent_locality: T.nilable(String),
            parsed_fields: ValidationTranscriber::ParsedAddress,
          ).returns(ValidationTranscriber::ParsedAddress)
        end
        def address_from_conjecture(
          conjecture:,
          double_dependent_locality:,
          dependent_locality:,
          parsed_fields:
        )
          building_num = conjecture[:building_num]
          unit_type = conjecture[:unit_type]
          unit_num = conjecture[:unit_num]

          if conjecture[:street].present?
            street_parts = T.must(conjecture[:street]).split(",").map(&:strip)
            if street_parts.count >= 2
              dependent_street = street_parts.first
              street = T.must(street_parts[1..-1]).join(", ")
            else
              street = street_parts.first
            end
          end

          candidate = parsed_fields.dup

          candidate.building_num = building_num if building_num.present?
          candidate.dependent_street = dependent_street if dependent_street.present?
          candidate.street = street if street.present?
          candidate.unit_type = unit_type if unit_type.present?
          candidate.unit_num = unit_num if unit_num.present?
          candidate.double_dependent_locality = double_dependent_locality if double_dependent_locality.present?
          candidate.dependent_locality = dependent_locality if dependent_locality.present?

          candidate
        end

        sig do
          params(
            street_components: T::Array[String],
            locality_components: T::Array[String],
            parsed_fields: ValidationTranscriber::ParsedAddress,
          ).returns(T::Array[ValidationTranscriber::ParsedAddress])
        end
        def hypothesize(street_components:, locality_components:, parsed_fields:)
          double_dependent_locality = locality_components.first if locality_components.count >= 2
          dependent_locality = locality_components.last if locality_components.count >= 1

          address_line = street_components.join(", ")
          conjectures = if parsed_fields.country_code.present?
            AtlasEngine::ValidationTranscriber::AddressParserFactory.create(
              address: build_address(
                address1: address_line,
                country_code: parsed_fields.country_code.to_s,
              ),
            ).parse
          end

          if conjectures.blank?
            conjectures = [{ street: address_line }]
          end

          conjectures.map do |conjecture|
            address_from_conjecture(
              conjecture: conjecture,
              double_dependent_locality: double_dependent_locality,
              dependent_locality: dependent_locality,
              parsed_fields: parsed_fields,
            )
          end
        end

        # Identify and return the "components" of the address
        # These are portions of the address1 and/or address2 lines that have been separated by
        # line break and/or by commas.
        # For example,
        #   123 High Street, Flat 4
        #   Lower Hangleton, Swindon
        # will return 4 components:
        #   ["123 High Street", "Flat 4", "Lower Hangleton", "Swindon"]
        sig { params(address: AtlasEngine::AddressValidation::AbstractAddress).returns(T::Array[String]) }
        def split_into_components(address)
          [address.address1&.split(","), address.address2&.split(",")].flatten.compact.map(&:strip)
        end
      end
    end
  end
end
