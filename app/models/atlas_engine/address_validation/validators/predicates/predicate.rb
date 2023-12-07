# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module Predicates
        class Predicate
          extend T::Helpers
          extend T::Sig
          abstract!

          sig { returns(Symbol) }
          attr_reader :field

          sig { returns(Address) }
          attr_reader :address

          sig { returns(Cache) }
          attr_reader :cache

          delegate :address1, :address2, :city, :zip, :province_code, :country_code, to: :address

          sig { params(field: Symbol, address: Address, cache: Cache).void }
          def initialize(field:, address:, cache: Cache.new(address))
            @field = field
            @address = address
            @cache = cache
          end

          sig { abstract.returns(T.nilable(Concern)) }
          def evaluate; end
        end
      end
    end
  end
end
