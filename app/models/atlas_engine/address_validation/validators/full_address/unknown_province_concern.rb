# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownProvinceConcern < AddressValidation::Concern
          include ConcernFormatter
          attr_reader :address

          sig { params(address: AbstractAddress, suggestion_ids: T::Array[String]).void }
          def initialize(address, suggestion_ids)
            @address = address
            super(
              code: :province_inconsistent,
              field_names: [:province],
              message: message,
              type: T.must(Concern::TYPES[:error]),
              type_level: 1,
              suggestion_ids: suggestion_ids
            )
          end

          sig { returns(String) }
          def message
            country
              .field(key: :province)
              .error(
                code: :unknown_for_city_and_zip,
                options: { city: address.city, zip: address.zip },
              ).to_s
          end
        end
      end
    end
  end
end
