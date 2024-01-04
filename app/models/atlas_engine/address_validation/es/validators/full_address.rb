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

            street_sequences_future = session.datastore.fetch_street_sequences_async
            city_sequences_future = session.datastore.fetch_city_sequence_async
            best_candidate = sorted_candidates.first

            begin
              if best_candidate.nil?
                AddressValidation::Validators::FullAddress::NoCandidateResult.new(session:, result:)
              else
                AddressValidation::Validators::FullAddress::CandidateResult.new(
                  candidate: best_candidate,
                  result: result,
                  session: session,
                )
              end
            ensure
              # We want our futures to complete even when we do not consume their value.
              street_sequences_future.wait!
              city_sequences_future.wait!
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

          sig { returns(T::Array[CandidateTuple]) }
          def sorted_candidates
            @sorted_candidates ||= begin
              sorted_candidate_tuples = session.datastore.fetch_full_address_candidates
                .filter_map.with_index(1) do |candidate, position|
                  tuple = CandidateTuple.new(address_comparison(candidate), position, candidate)
                  tuple if tuple.address_comparison.potential_match?
                end.sort

              emit_sorted_candidates(sorted_candidate_tuples)
              sorted_candidate_tuples
            end
          end

          sig { params(candidate: Candidate).returns(AddressValidation::Validators::FullAddress::AddressComparison) }
          def address_comparison(candidate)
            AddressValidation::Validators::FullAddress::AddressComparison.new(
              street_comparison: AddressValidation::Validators::FullAddress::ComparisonHelper.street_comparison(
                session: session, candidate: candidate,
              ),
              city_comparison: AddressValidation::Validators::FullAddress::ComparisonHelper.city_comparison(
                session: session, candidate: candidate,
              ),
              zip_comparison: AddressValidation::Validators::FullAddress::ComparisonHelper.zip_comparison(
                session: session, candidate: candidate,
              ),
              province_code_comparison: AddressValidation::Validators::FullAddress::ComparisonHelper
              .province_code_comparison(
                session: session, candidate: candidate,
              ),
              building_comparison: AddressValidation::Validators::FullAddress::ComparisonHelper.building_comparison(
                session: session, candidate: candidate,
              ),
            )
          end

          sig { params(sorted_candidate_tuples: T::Array[CandidateTuple]).void }
          def emit_sorted_candidates(sorted_candidate_tuples)
            log_info("Sorted candidates:\n #{sorted_candidate_tuples.map { |tuple| tuple.candidate.serialize }}")

            initial_position_top_candidate = sorted_candidate_tuples.first&.position || 0
            StatsD.distribution(
              "AddressValidation.query.initial_position_top_candidate",
              initial_position_top_candidate,
              tags: { position: initial_position_top_candidate },
            )
          end
        end
      end
    end
  end
end
