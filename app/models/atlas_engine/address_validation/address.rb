# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    class Address < T::Struct
      extend T::Sig
      include LogHelper
      include AbstractAddress

      ComponentType = T.type_alias { T.nilable(String) }
      CountryType = T.type_alias { T.nilable(T.any(String, Symbol)) }
      AddressInput = T.type_alias { Types::AddressValidation::AddressInput }

      const :address1, ComponentType
      const :address2, ComponentType
      const :city, ComponentType
      const :province_code, ComponentType
      const :phone, ComponentType
      const :country_code, CountryType
      const :zip, ComponentType

      sig { override.returns(T::Hash[Symbol, T.untyped]) }
      def context = {}

      sig { override.returns(T::Hash[Symbol, String]) }
      def to_h = serialize.transform_keys(&:to_sym)

      class << self
        extend T::Sig

        sig { params(address: TAddress).returns(Address) }
        def from_address(address:)
          new(
            address1: address.address1,
            address2: address.address2,
            city: address.city,
            country_code: address.country_code,
            province_code: address.province_code,
            zip: address.zip,
            phone: address.phone,
          )
        end
      end
    end
  end
end
