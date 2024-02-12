# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipForCountryConcern < AddressValidation::Concern
          include ConcernFormatter
          attr_reader :address

          sig { params(country: Worldwide::Region, address: AbstractAddress, suggestion_ids: T::Array[String]).void }
          def initialize(country, address, suggestion_ids)
            @address = address

            super(
              code: :zip_invalid_for_country,
              field_names: [:zip],
              message: message(country),
              type: T.must(Concern::TYPES[:error]),
              type_level: 1,
              suggestion_ids: suggestion_ids
            )
          end

          sig { params(country: Worldwide::Region).returns(String) }
          def message(country)
            country.field(key: :zip).error( # new country object here
              code: :invalid_for_country,
              options: { country: country.full_name },
            ).to_s
          end
        end
      end
    end
  end
end
