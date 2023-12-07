# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      module FieldValidations
        class Zip
          extend T::Sig
          extend T::Helpers
          include Interface

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
            @zip = address.zip
            @allow_partial_zip = allow_partial_zip
            @errors = []
          end

          sig { override.returns(T::Array[String]) }
          def validation_errors
            validate
            errors
          end

          private

          attr_reader :country_code, :province_code, :zip

          def validate
            return unless country.country?

            zip_must_match_country
            return if errors.any?

            zip_must_match_province
          end

          def zip_must_match_country
            return unless country.has_zip?

            if zip.blank? && country.zip_required?
              errors << "Zip is required for country '#{country_code}'"
            elsif !zip_valid_for_country?
              errors << "Zip '#{zip}' is invalid for country '#{country_code}'"
            end
          end

          def zip_must_match_province
            province = country.zone(code: province_code) unless country.province_optional?

            return unless province&.province?
            return if province.valid_zip?(zip)
            return if @allow_partial_zip && province.valid_zip?(zip, partial_match: true)

            errors << "Zip '#{zip}' is invalid for province '#{province_code}'"
          end

          def zip_valid_for_country?
            country.valid_zip?(zip) ||
              (@allow_partial_zip && country.valid_zip?(zip, partial_match: true))
          end

          def partial_postal_code_valid_for_province?
            country.zone(code: province_code).valid_zip?(zip, partial_match: true)
          end

          def country
            @country ||= Worldwide.region(code: country_code)
          end
        end
      end
    end
  end
end
