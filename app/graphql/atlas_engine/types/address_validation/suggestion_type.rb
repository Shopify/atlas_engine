# typed: false
# frozen_string_literal: true

module AtlasEngine
  module Types
    module AddressValidation
      class SuggestionType < BaseObject
        description "An address-like object containing some value corrections derived during address validation"

        field :id, String, null: false
        field :address1, String, null: true
        field :address2, String, null: true
        field :city, String, null: true
        field :zip, String, null: true
        field :province_code, String, null: true
        field :province, String, null: true
        field :country_code, ValidationSupportedCountry, null: true
      end
    end
  end
end
