# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      class Wrapper
        extend T::Sig

        include Validator
        include ImportLogHelper

        attr_reader :country_import, :validator

        AddressStruct = Struct.new(:country_code, :province_code, :zip, :city, keyword_init: true)

        sig do
          params(
            country_import: CountryImport,
            validator: T.nilable(AddressImporter::Validation::BaseValidator),
            log_invalid_records: T.nilable(T::Boolean),
          ).void
        end
        def initialize(country_import:, validator: nil, log_invalid_records: true)
          @country_import = country_import
          @validator = validator || DefaultValidator.new(country_code: country_import.country_code)
          @log_invalid_records = log_invalid_records
        end

        sig { override.params(address: T.nilable(Hash)).returns(T::Boolean) }
        def valid?(address)
          return false unless address

          errors = validation_errors(address)

          return true if errors.empty?

          log_invalid_address(address, errors) if @log_invalid_records
          false
        end

        private

        sig { params(address: Hash).returns(T::Array[String]) }
        def validation_errors(address)
          validator.validation_errors(
            address: address_from_hash(address),
          ).values.flatten
        end

        sig { params(address_hash: Hash).returns(AddressStruct) }
        def address_from_hash(address_hash)
          AddressStruct.new(**address_hash.slice(:country_code, :province_code, :zip, :city))
        end

        sig { params(address: Hash, errors: T::Array[String]).void }
        def log_invalid_address(address, errors)
          errors.each do |error|
            import_log_info(
              country_import: country_import,
              message: "Invalid address; #{error}",
              category: :invalid_address,
              additional_params: { address: address },
            )
          end
        end
      end
    end
  end
end
