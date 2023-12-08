# typed: true
# frozen_string_literal: true

module AtlasEngine
  module Services
    class Validation
      extend T::Sig
      VALIDATE_ADDRESS = "validate_address"

      class << self
        extend T::Sig
        include ServiceHelper
        T.unsafe(self).include(AtlasEngine.validation_eligibility.constantize)

        sig { params(request: AddressValidation::Request).returns(AddressValidation::Result) }
        def validate_address(request)
          country_code = request.address.country_code
          handle_metrics(Validation::VALIDATE_ADDRESS, country_code, false) do
            matching_strategy = if validation_enabled?(request.address)
              serialize_strategy(request.matching_strategy, request.address)
            else
              AddressValidation::MatchingStrategies::Local
            end

            validator = AddressValidation::Validator.new(
              address: request.address,
              locale: request.locale,
              matching_strategy: matching_strategy,
              context: request.address.context.to_h,
            )
            result = validator.run

            AddressValidation::StatsdEmitter.new(address: request.address, result: result).run
            AddressValidation::LogEmitter.new(address: request.address, result: result).run

            if Rails.configuration.x.captured_concerns.enabled
              AddressValidation::ConcernProducer.add(result, request.address.context.to_h)
            end

            result
          end
        end

        private

        sig do
          params(
            request_matching_strategy: T.nilable(T.any(String, Symbol)),
            address: AddressValidation::AbstractAddress,
          ).returns(AddressValidation::MatchingStrategies)
        end
        def serialize_strategy(request_matching_strategy, address)
          requested_strategy = if request_matching_strategy.nil?
            CountryProfile.for(T.must(address.country_code)).validation.default_matching_strategy
          else
            request_matching_strategy.to_s.downcase
          end

          serialized_strategy = AddressValidation::MatchingStrategies.try_deserialize(requested_strategy)
          serialized_strategy.presence || AddressValidation::MatchingStrategies::Local
        end
      end
    end
  end
end
