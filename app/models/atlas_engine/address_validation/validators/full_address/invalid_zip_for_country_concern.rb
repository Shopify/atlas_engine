# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipForCountryConcern < AddressValidation::Concern
          include ConcernFormatter
          attr_reader :address

          sig { params(address: Types::AddressValidation::AddressInput, suggestion_ids: T::Array[String]).void }
          def initialize(address, suggestion_ids)
            @address = address

            super(
              code: :zip_invalid_for_country,
              field_names: [:zip],
              message: message,
              type: T.must(Concern::TYPES[:error]),
              type_level: 1,
              suggestion_ids: suggestion_ids
            )
          end

          sig { returns(String) }
          def message
            country.field(key: :zip).error(
              code: :invalid_for_country,
              options: { country: country.full_name },
            ).to_s
          end
        end
      end
    end
  end
end
