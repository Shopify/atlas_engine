# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class InvalidZipForProvinceConcern < AddressValidation::Concern
          include ConcernFormatter
          attr_reader :address

          sig { params(country: Worldwide::Region, address: AbstractAddress, suggestion_ids: T::Array[String]).void }
          def initialize(country, address, suggestion_ids)
            @address = address

            super(
              code: :zip_invalid_for_province,
              field_names: [:zip],
              message: message(country),
              type: T.must(Concern::TYPES[:error]),
              type_level: 1,
              suggestion_ids: suggestion_ids
            )
          end

          sig { params(country: Worldwide::Region).returns(String) }
          def message(country)
            country.field(key: :zip).error(
              code: :invalid_for_province,
              options: { province: province_name },
            ).to_s
          end
        end
      end
    end
  end
end
