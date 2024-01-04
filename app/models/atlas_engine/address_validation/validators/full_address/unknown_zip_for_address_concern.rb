# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownZipForAddressConcern < AddressValidation::Concern
          attr_reader :address

          sig { params(address: AbstractAddress, suggestion_ids: T::Array[String]).void }
          def initialize(address, suggestion_ids)
            @address = address
            super(
              code: :zip_inconsistent,
              field_names: [:zip],
              message: message,
              type: T.must(Concern::TYPES[:warning]),
              type_level: 3,
              suggestion_ids: suggestion_ids
            )
          end

          sig { returns(String) }
          def message
            "Enter a valid ZIP for #{address.address1}, #{address.city}"
          end
        end
      end
    end
  end
end
