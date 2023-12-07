# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressImporter
    module Validation
      class DefaultValidator < BaseValidator
        extend T::Sig

        sig { params(country_code: String).void }
        def initialize(country_code:)
          field_validations = {
            city: [FieldValidations::City],
            province_code: [FieldValidations::Province],
            zip: [FieldValidations::Zip],
          }

          super(
            country_code: country_code,
            field_validations: field_validations,
            additional_field_validations: AtlasEngine.address_importer_additional_field_validations,
          )
        end
      end
    end
  end
end
