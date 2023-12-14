# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      module FieldValidations
        class Province
          extend T::Sig

          extend T::Helpers
          include Interface

          sig { returns(String) }
          attr_reader :country_code

          sig { returns(T.nilable(String)) }
          attr_reader :province_code

          sig { returns(T::Array[String]) }
          attr_reader :errors

          sig do
            override.params(
              address: AddressImporter::Validation::Wrapper::AddressStruct,
              allow_partial_zip: T::Boolean,
            ).void
          end
          def initialize(address:, allow_partial_zip: false)
            @country_code = address.country_code
            @province_code = address.province_code
            @errors = []
          end

          sig { override.returns(T::Array[String]) }
          def validation_errors
            validate_country
            validate_province if errors.empty?
            errors
          end

          private

          sig { void }
          def validate_country
            errors << "Country '#{country_code}' is invalid" unless country.country?
          end

          sig { void }
          def validate_province
            return unless country_has_provinces?

            if province_code.blank?
              errors << "Province is required for country '#{country_code}'" unless country.province_optional?
            elsif !country.zone(code: province_code).province?
              errors << "Province '#{province_code}' is invalid for country '#{country_code}'"
            end
          end

          sig { returns(Worldwide::Region) }
          def country
            @country ||= Worldwide.region(code: country_code)
          end

          sig { returns(T::Boolean) }
          def country_has_provinces?
            country.zones.present? && !country.hide_provinces_from_addresses
          end
        end
      end
    end
  end
end
