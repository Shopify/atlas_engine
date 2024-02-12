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

          sig { params(country: Worldwide::Region, address: TAddress).void }
          def initialize(country, address)
            @address = address
            super(
              code: :address_unknown,
              message: country.field(key: :address).error(code: :may_not_exist),
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
