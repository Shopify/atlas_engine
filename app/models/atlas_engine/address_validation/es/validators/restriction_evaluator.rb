# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class RestrictionEvaluator
          extend T::Sig
          attr_reader :address

          sig { params(address: AtlasEngine::AddressValidation::AbstractAddress).void }
          def initialize(address)
            @address = address
          end

          sig { returns(T::Boolean) }
          def supported_address?
            country_profile = CountryProfile.for(T.must(address.country_code))

            country_profile.attributes.dig("validation", "restrictions").map do |restriction|
              class_name = restriction["class"]
              additional_params = restriction["params"]&.transform_keys(&:to_sym)

              params = { address: address }
              params = params.merge!({ params: additional_params }) if additional_params.present?

              return false if class_name.constantize.send(:apply?, **params)
            end

            true
          end
        end
      end
    end
  end
end
