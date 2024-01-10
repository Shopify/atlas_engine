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
                datastore: DatastoreBase,
                candidate: Candidate,
              ).returns(T.nilable(Token::Sequence::Comparison))
            end
            def street_comparison(datastore:, candidate:)
              street_sequences = datastore.fetch_street_sequences
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
                datastore: DatastoreBase,
                candidate: Candidate,
              ).returns(T.nilable(Token::Sequence::Comparison))
            end
            def city_comparison(datastore:, candidate:)
              best_comparison(
                datastore.fetch_city_sequence,
                T.must(candidate.component(:city)).sequences,
              )
            end

            sig do
              params(
                address: AbstractAddress,
                candidate: Candidate,
              ).returns(T.nilable(Token::Sequence::Comparison))
            end
            def province_code_comparison(address:, candidate:)
              normalized_session_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
                country_code: address.country_code,
                province_code: address.province_code,
              )
              normalized_candidate_province_code = ValidationTranscriber::ProvinceCodeNormalizer.normalize(
                country_code: T.must(candidate.component(:country_code)).value,
                province_code: T.must(candidate.component(:province_code)).value,
              )

              best_comparison(
                Token::Sequence.from_string(normalized_session_province_code),
                [Token::Sequence.from_string(normalized_candidate_province_code)],
              )
            end

            sig do
              params(
                address: AbstractAddress,
                candidate: Candidate,
              ).returns(T.nilable(Token::Sequence::Comparison))
            end
            def zip_comparison(address:, candidate:)
              candidate.component(:zip)&.value = PostalCodeMatcher.new(
                T.must(address.country_code),
                T.must(address.zip),
                candidate.component(:zip)&.value,
              ).truncate

              normalized_zip = ValidationTranscriber::ZipNormalizer.normalize(
                country_code: address.country_code, zip: address.zip,
              )
              zip_sequence = Token::Sequence.from_string(normalized_zip)
              best_comparison(
                zip_sequence,
                T.must(candidate.component(:zip)).sequences,
              )
            end

            sig do
              params(
                datastore: DatastoreBase,
                candidate: Candidate,
              ).returns(NumberComparison)
            end
            def building_comparison(datastore:, candidate:)
              NumberComparison.new(
                numbers: datastore.parsings.potential_building_numbers,
                candidate_ranges: building_ranges_from_candidate(candidate),
              )
            end

            private

            sig do
              params(
                sequence: Token::Sequence,
                component_sequences: T::Array[Token::Sequence],
              ).returns(T.nilable(Token::Sequence::Comparison))
            end
            def best_comparison(sequence, component_sequences)
              component_sequences.map do |component_sequence|
                Token::Sequence::Comparator.new(
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
