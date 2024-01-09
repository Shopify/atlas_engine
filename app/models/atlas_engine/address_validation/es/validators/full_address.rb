# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class FullAddress < FullAddressValidatorBase
          include LogHelper

          attr_reader :address, :result
          attr_accessor :session

          sig { params(address: TAddress, result: Result).void }
          def initialize(address:, result: Result.new)
            super
            @session = T.let(Session.new(address: address, matching_strategy: MatchingStrategies::Es), Session)
          end

          sig { override.returns(Result) }
          def validate
            return result if concerns_preclude_validation

            candidate_result = build_candidate_result
            candidate_result.update_result
            publish_notification(candidate_result: candidate_result)
            result
          end

          def build_candidate_result
            unless supported_address?(address)
              return AddressValidation::Validators::FullAddress::UnsupportedScriptResult.new(session:, result:)
            end

            best_candidate = AddressValidation::Es::CandidateSelector.new(
              datastore: session.datastore,
              address: session.address,
            ).best_candidate

            if best_candidate.nil?
              AddressValidation::Validators::FullAddress::NoCandidateResult.new(session:, result:)
            else
              AddressValidation::Validators::FullAddress::CandidateResult.new(
                candidate: best_candidate,
                result: result,
                session: session,
              )
            end
          end

          private

          sig do
            params(candidate_result: T.nilable(AddressValidation::Validators::FullAddress::CandidateResultBase))
              .returns(T.untyped)
          end
          def publish_notification(candidate_result: nil)
            ActiveSupport::Notifications.instrument("atlas-engine.address_validation.validation_completed", {
              candidate_result: candidate_result,
              result: result,
            }.compact)
          end

          sig { returns(T::Boolean) }
          def concerns_preclude_validation
            has_error_concerns? || exceeds_max_token_length?
          end

          sig { returns(T::Boolean) }
          def has_error_concerns?
            error_concerns = result.concerns.select { |concern| concern.type == Concern::TYPES[:error] }
            error_concerns.flat_map(&:field_names).intersect?([
              :country,
              :province,
              :city,
              :zip,
              :address1,
              :address2,
            ])
          end

          sig { returns(T::Boolean) }
          def exceeds_max_token_length?
            result.concerns.flat_map(&:code).intersect?([
              :address1_contains_too_many_words,
              :address2_contains_too_many_words,
            ])
          end

          sig { params(address: TAddress).returns(T::Boolean) }
          def supported_address?(address)
            country_profile = CountryProfile.for(T.must(address.country_code))
            restrictions = country_profile.validation.validation_restrictions
            restrictions.none? { |restriction| restriction.apply?(address) }
          end
        end
      end
    end
  end
end
