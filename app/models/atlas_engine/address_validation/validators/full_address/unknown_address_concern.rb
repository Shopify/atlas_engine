# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class UnknownAddressConcern < AddressValidation::Concern
          include ConcernFormatter

          sig { returns(TAddress) }
          attr_reader :address

          sig { params(address: TAddress).void }
          def initialize(address)
            @address = address
            super(
              code: :address_unknown,
              message: Worldwide.region(code: address.country_code).field(key: :address).error(code: :may_not_exist),
              type: T.must(Concern::TYPES[:warning]),
              type_level: 1,
              suggestion_ids: [],
              field_names: [:address1],
            )
          end
        end
      end
    end
  end
end
