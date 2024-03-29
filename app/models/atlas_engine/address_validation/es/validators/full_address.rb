# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Es
      module Validators
        class FullAddress < FullAddressValidatorBase
          include LogHelper

          attr_reader :address, :result

          sig { params(address: TAddress, result: Result).void }
          def initialize(address:, result: Result.new)
            super
            @matching_strategy = MatchingStrategies::Es
          end

          sig { override.returns(Result) }
          def validate
            return result if concerns_preclude_validation

            candidate_result = build_candidate_result
            candidate_result.update_result
            publish_notification(candidate_result: candidate_result)
            result
          end

          sig { returns(AddressValidation::Validators::FullAddress::CandidateResultBase) }
          def build_candidate_result
            unless supported_address?(address)
              return AddressValidation::Validators::FullAddress::UnsupportedScriptResult.new(address:, result:)
            end

            if best_candidate.nil?
              AddressValidation::Validators::FullAddress::NoCandidateResult.new(address:, result:)
            else
              AddressValidation::Validators::FullAddress::CandidateResult.new(
                address_comparison: T.must(best_candidate),
                matching_strategy: @matching_strategy,
                result: result,
              )
            end
          end

          private

          sig { returns(T.nilable(AddressValidation::Validators::FullAddress::AddressComparison)) }
          def best_candidate
            @best_candidate ||= T.let(
              begin
                index_locales = CountryProfile.for(address.country_code).validation.index_locales

                candidate_futures = if index_locales.empty?
                  [best_candidate_future]
                else
                  index_locales.map { |locale| best_candidate_future(locale) }
                end

                candidate_futures.filter_map(&:value!).min
              ensure
                # We want our futures to complete even when we do not consume their value.
                candidate_futures&.map(&:wait!)
              end,
              T.nilable(AddressValidation::Validators::FullAddress::AddressComparison),
            )
          end

          sig { params(locale: T.nilable(String)).returns(Concurrent::Promises::Future) }
          def best_candidate_future(locale = nil)
            AddressValidation::Es::CandidateSelector.new(
              datastore: Es::Datastore.new(address: address, locale: locale),
              address: address,
            ).best_candidate_async
          end

          sig do
            params(candidate_result: T.nilable(AddressValidation::Validators::FullAddress::CandidateResultBase))
              .returns(T.untyped)
          end
          def publish_notification(candidate_result: nil)
            ActiveSupport::Notifications.instrument("atlas_engine.address_validation.validation_completed", {
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
            RestrictionEvaluator.new(address).supported_address?
          end
        end
      end
    end
  end
end
