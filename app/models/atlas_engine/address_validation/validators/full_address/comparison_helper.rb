# typed: true
# frozen_string_literal: true

module AtlasEngine
  module AddressValidation
    module Validators
      module FullAddress
        class ComparisonHelper
          class << self
            extend T::Sig

            sig do
              params(
                session: Session,
                candidate: Candidate,
              ).returns(T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison))
            end
            def street_comparison(session:, candidate:)
              street_sequences = session.datastore.fetch_street_sequences
              candidate_sequences = T.must(candidate.component(:street)).sequences

              street_sequences.map do |street_sequence|
                best_comparison(
                  street_sequence,
                  candidate_sequences,
                )
              end.min
            end

            sig do
              params(
                session: Session,
                candidate: Candidate,
              ).returns(T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison))
            end
            def city_comparison(session:, candidate:)
              best_comparison(
                session.datastore.fetch_city_sequence,
                T.must(candidate.component(:city)).sequences,
              )
            end

            sig do
              params(
                session: Session,
                candidate: Candidate,
              ).returns(T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison))
            end
            def province_code_comparison(session:, candidate:)
              normalized_session_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
                country_code: session.country_code,
                province_code: session.province_code,
              )
              normalized_candidate_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
                country_code: T.must(candidate.component(:country_code)).value,
                province_code: T.must(candidate.component(:province_code)).value,
              )

              best_comparison(
                AtlasEngine::AddressValidation::Token::Sequence.from_string(normalized_session_province_code),
                [AtlasEngine::AddressValidation::Token::Sequence.from_string(normalized_candidate_province_code)],
              )
            end

            sig do
              params(
                session: Session,
                candidate: Candidate,
              ).returns(T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison))
            end
            def zip_comparison(session:, candidate:)
              candidate.component(:zip)&.value = PostalCodeMatcher.new(
                session.country_code,
                session.zip,
                candidate.component(:zip)&.value,
              ).truncate

              normalized_zip = ValidationTranscriber::ZipNormalizer.normalize(
                country_code: session.country_code, zip: session.zip,
              )
              zip_sequence = AtlasEngine::AddressValidation::Token::Sequence.from_string(normalized_zip)
              best_comparison(
                zip_sequence,
                T.must(candidate.component(:zip)).sequences,
              )
            end

            sig do
              params(
                session: Session,
                candidate: Candidate,
              ).returns(NumberComparison)
            end
            def building_comparison(session:, candidate:)
              NumberComparison.new(
                numbers: session.parsings.potential_building_numbers,
                candidate_ranges: building_ranges_from_candidate(candidate),
              )
            end

            private

            sig do
              params(
                sequence: AtlasEngine::AddressValidation::Token::Sequence,
                component_sequences: T::Array[AtlasEngine::AddressValidation::Token::Sequence],
              ).returns(T.nilable(AtlasEngine::AddressValidation::Token::Sequence::Comparison))
            end
            def best_comparison(sequence, component_sequences)
              component_sequences.map do |component_sequence|
                AtlasEngine::AddressValidation::Token::Sequence::Comparator.new(
                  left_sequence: sequence,
                  right_sequence: component_sequence,
                ).compare
              end.min_by.with_index do |comparison, index|
                # ruby's `min` and `sort` methods are not stable
                # so we need to prefer the leftmost comparison when two comparisons are equivalent
                [comparison, index]
              end
            end

            sig { params(candidate: Candidate).returns(T::Array[AddressNumberRange]) }
            def building_ranges_from_candidate(candidate)
              building_and_unit_ranges = candidate.component(:building_and_unit_ranges)&.value
              return [] if building_and_unit_ranges.blank?

              building_ranges = JSON.parse(building_and_unit_ranges).keys
              building_ranges.map { |building_range| AddressNumberRange.new(range_string: building_range) }
            end
          end
        end
      end
    end
  end
end
