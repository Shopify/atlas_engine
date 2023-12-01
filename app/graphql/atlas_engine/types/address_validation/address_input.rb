# typed: strict
# frozen_string_literal: true

module AtlasEngine
  module Types
    module AddressValidation
      class AddressInput < GraphQL::Schema::InputObject
        extend T::Sig
        include LogHelper
        include AtlasEngine::AddressValidation::AbstractAddress

        description "Address fields used to fulfill a validation request"

        argument :address1, String, required: false
        argument :address2, String, required: false
        argument :city, String, required: false
        argument :country_code, ValidationSupportedCountry, required: false
        argument :province_code, String, required: false
        argument :zip, String, required: false
        argument :phone, String, required: false

        sig { returns(T::Hash[T.untyped, T.untyped]) }
        def marshal_dump
          to_kwargs
        end

        sig { params(hash: T::Hash[T.untyped, T.untyped]).void }
        def marshal_load(hash)
          @ruby_style_hash = T.let(hash, T.nilable(T::Hash[T.untyped, T.untyped]))
        end

        class << self
          extend T::Sig

          sig do
            params(hash: T::Hash[Symbol, T.untyped])
              .returns(AddressInput)
          end
          def from_hash(hash)
            new(
              nil,
              ruby_kwargs: hash,
              context: nil,
              defaults_used: nil,
            )
          end
        end
      end
    end
  end
end
